output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network."
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their Azure Resource IDs."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their assigned CIDR prefixes."
  value       = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes }
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = try(azurerm_network_security_group.nsg[0].id, null)
}

output "route_table_id" {
  description = "The ID of the custom Route Table."
  value       = try(azurerm_route_table.route_table[0].id, null)
}

