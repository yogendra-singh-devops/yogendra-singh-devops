# ------------------------------------------------------------------------------
# Zero-Trust PaaS Private Endpoints with Dynamic DNS Groups
# ------------------------------------------------------------------------------

resource "azurerm_private_endpoint" "pe" {
  for_each = var.endpoints

  name                = "pe-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  # Dynamic Private Service Connection
  dynamic "private_service_connection" {
    for_each = [1]
    content {
      name                           = "psc-${each.key}"
      private_connection_resource_id = each.value.target_resource_id
      subresource_names              = each.value.subresource_names
      is_manual_connection           = each.value.is_manual_connection
      request_message                = each.value.request_message
    }
  }

  # Dynamic DNS Zone Group for automatic private record registration
  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default-dns-group"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

