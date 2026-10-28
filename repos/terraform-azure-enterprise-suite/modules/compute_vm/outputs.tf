output "vm_ids" {
  description = "Map of VM names to their Resource IDs."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_private_ips" {
  description = "Map of VM names to their private IP addresses."
  value       = { for k, v in azurerm_network_interface.nic : k => v.ip_configuration[0].private_ip_address }
}

output "vm_principal_ids" {
  description = "Map of VM names to their system-assigned Managed Identity principal IDs."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.identity[0].principal_id }
}

