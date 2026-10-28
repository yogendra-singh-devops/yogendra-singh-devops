output "dns_zone_ids" {
  description = "Map of Private DNS Zone names to their Resource IDs."
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}

output "dns_zone_names" {
  description = "List of created Private DNS Zone names."
  value       = keys(azurerm_private_dns_zone.zones)
}

