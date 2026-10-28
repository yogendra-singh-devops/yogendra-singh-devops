output "private_endpoint_ids" {
  description = "Map of endpoint names to Resource IDs."
  value       = { for k, v in azurerm_private_endpoint.pe : k => v.id }
}

output "private_ip_addresses" {
  description = "Map of endpoint names to their assigned private IP addresses."
  value = {
    for k, v in azurerm_private_endpoint.pe :
    k => v.private_service_connection[0].private_ip_address
  }
}

