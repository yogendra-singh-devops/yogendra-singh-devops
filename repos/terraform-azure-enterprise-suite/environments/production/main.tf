# ==============================================================================
# ENTERPRISE AZURE PRODUCTION LANDING ZONE BLUEPRINT
# Architect & Author: Yogendra Singh (DevOps Engineer)
# Demonstrating: for_each, map(object), dynamic blocks & modular orchestration
# ==============================================================================

# 1. Primary Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}-001"
  location = var.location
  tags     = var.common_tags
}

# 2. Central Log Analytics Workspace (Enterprise Observability)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project_name}-${var.environment}-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.common_tags
}

# 3. Enterprise Networking (Hub-and-Spoke Spoke VNet with dynamic Subnets & NSG)
module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-${var.project_name}-${var.environment}-001"
  address_space       = ["10.20.0.0/16"]

  # Map of subnets provisioned via for_each in module
  subnets = {
    "snet-aks-system" = {
      address_prefixes  = ["10.20.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }
    "snet-aks-workloads" = {
      address_prefixes  = ["10.20.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-backend-data" = {
      address_prefixes  = ["10.20.3.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "snet-cicd-runners" = {
      address_prefixes  = ["10.20.4.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-private-endpoints" = {
      address_prefixes                          = ["10.20.5.0/24"]
      private_endpoint_network_policies_enabled = true
    }
  }

  # Map of security rules rendered via dynamic blocks in module
  nsg_rules = {
    "Allow-HTTPS-Inbound" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow inbound TLS traffic"
    }
    "Allow-Internal-VNet-Sync" = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow inter-subnet spoke communication"
    }
    "Deny-Direct-Internet-Inbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Zero-Trust default internet ingress drop"
    }
  }

  # Map of custom routes rendered via dynamic blocks in module
  custom_routes = {
    "Route-To-Central-Firewall" = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.10.1.4" # Hub Azure Firewall Private IP
    }
  }

  tags = var.common_tags
}

# 4. Enterprise Storage Account with dynamic firewall & containers
module "storage_account" {
  source = "../../modules/storage_account"

  storage_account_name     = "st${var.project_name}${var.environment}data01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-Redundant for BCP & High Availability
  blob_retention_days      = 30

  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = [
      module.networking.subnet_ids["snet-aks-system"],
      module.networking.subnet_ids["snet-cicd-runners"]
    ]
  }

  containers = {
    "app-artifacts" = {
      container_access_type = "private"
      metadata              = { tier = "production", classification = "restricted" }
    }
    "database-backups" = {
      container_access_type = "private"
      metadata              = { retention = "30days", backup = "true" }
    }
  }

  tags = var.common_tags
}

# 5. Azure Key Vault with dynamic Access Policies
module "key_vault" {
  source = "../../modules/key_vault"

  key_vault_name             = "kv-${var.project_name}-${var.environment}-001"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = [
      module.networking.subnet_ids["snet-aks-system"],
      module.networking.subnet_ids["snet-cicd-runners"]
    ]
  }

  access_policies = {
    "current-deployment-sp" = {
      object_id          = module.storage_account.principal_id
      secret_permissions = ["Get", "List"]
    }
  }

  secrets = {
    "db-connection-string" = {
      value        = "Server=tcp:sql-srv.database.windows.net;Database=proddb;"
      content_type = "connection-string"
    }
  }

  tags = var.common_tags
}

# 6. Production Azure Kubernetes Service (AKS) with dynamic node pools
module "aks" {
  source = "../../modules/aks_cluster"

  cluster_name               = "aks-${var.project_name}-${var.environment}-001"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  dns_prefix                 = "aks-${var.project_name}-${var.environment}"
  kubernetes_version         = "1.28.3"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Default System Node Pool
  default_node_pool = {
    name                = "syspool"
    vm_size             = "Standard_D4s_v5"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    vnet_subnet_id      = module.networking.subnet_ids["snet-aks-system"]
  }

  # Additional User/Workload Node Pools provisioned via for_each
  additional_node_pools = {
    "userpool1" = {
      vm_size             = "Standard_D8s_v5"
      node_count          = 2
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 8
      os_disk_size_gb     = 256
      vnet_subnet_id      = module.networking.subnet_ids["snet-aks-workloads"]
      node_labels         = { workload = "ecommerce", tier = "backend" }
      node_taints         = []
      mode                = "User"
    }
    "memorypool" = {
      vm_size             = "Standard_E4s_v5"
      node_count          = 1
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 4
      os_disk_size_gb     = 128
      vnet_subnet_id      = module.networking.subnet_ids["snet-aks-workloads"]
      node_labels         = { workload = "caching", app = "redis" }
      node_taints         = ["workload=caching:NoSchedule"]
      mode                = "User"
    }
  }

  tags = var.common_tags
}

# 7. Self-Hosted CI/CD Runner Compute instances
module "compute_vm" {
  source = "../../modules/compute_vm"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  vms = {
    "vm-cicd-runner-01" = {
      vm_size        = "Standard_D4s_v5"
      admin_username = "azureuser"
      ssh_public_key = var.ssh_public_key
      subnet_id      = module.networking.subnet_ids["snet-cicd-runners"]
    }
  }

  tags = var.common_tags
}

