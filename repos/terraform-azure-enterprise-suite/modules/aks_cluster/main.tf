# ------------------------------------------------------------------------------
# Production Enterprise Azure Kubernetes Service (AKS)
# ------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = var.default_node_pool.name
    vm_size             = var.default_node_pool.vm_size
    node_count          = var.default_node_pool.node_count
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id      = var.default_node_pool.vnet_subnet_id
    type                = "VirtualMachineScaleSets"
    tags                = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  # Dynamic Network Profile
  dynamic "network_profile" {
    for_each = [var.network_profile]
    content {
      network_plugin    = network_profile.value.network_plugin
      network_policy    = network_profile.value.network_policy
      load_balancer_sku = network_profile.value.load_balancer_sku
      service_cidr      = network_profile.value.service_cidr
      dns_service_ip    = network_profile.value.dns_service_ip
    }
  }

  # Dynamic Azure Monitor Log Analytics (Container Insights)
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Dynamic Key Vault Secrets Store CSI Driver
  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_secret_store_csi_driver ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "2m"
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Additional Workload Node Pools (for_each over Map of Objects)
# ------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = each.value.vnet_subnet_id
  mode                  = each.value.mode
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  tags = var.tags
}

