# ------------------------------------------------------------------------------
# Centralized Private DNS Zones (Hub Architecture)
# ------------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.dns_zones)

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Advanced HCL: Flattening nested loop for Zone x VNet Link pairing
locals {
  zone_vnet_pairs = flatten([
    for zone_name, zone_obj in azurerm_private_dns_zone.zones : [
      for vnet_name, vnet_id in var.vnet_links : {
        key       = "${replace(zone_name, ".", "-")}--${vnet_name}"
        zone_name = zone_name
        vnet_name = vnet_name
        vnet_id   = vnet_id
      }
    ]
  ])
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = {
    for pair in local.zone_vnet_pairs : pair.key => pair
  }

  name                  = "link-${each.value.vnet_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.value.zone_name].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false

  tags = var.tags
}

