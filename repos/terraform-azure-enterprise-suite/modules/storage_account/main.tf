# ------------------------------------------------------------------------------
# Secure Enterprise Azure Storage Account
# ------------------------------------------------------------------------------

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = var.min_tls_version

  enable_https_traffic_only = true
  allow_nested_items_to_be_public = false

  identity {
    type = "SystemAssigned"
  }

  # Dynamic Blob Properties (Soft-delete & Versioning for BCP)
  dynamic "blob_properties" {
    for_each = var.blob_retention_days > 0 ? [1] : []
    content {
      delete_retention_policy {
        days = var.blob_retention_days
      }
      container_delete_retention_policy {
        days = var.blob_retention_days
      }
      versioning_enabled = true
    }
  }

  # Dynamic Network Rules (Firewall & Private Subnet Locking)
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
      bypass                     = network_rules.value.bypass
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Blob Containers Provisioned via for_each over Map of Objects
# ------------------------------------------------------------------------------

resource "azurerm_storage_container" "containers" {
  for_each = var.containers

  name                  = each.key
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = each.value.container_access_type
  metadata              = each.value.metadata
}

