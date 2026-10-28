output "resource_group_name" {
  description = "Name of the created Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "Virtual Network ID."
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Map of Subnet IDs."
  value       = module.networking.subnet_ids
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storage_account.storage_account_name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.key_vault.key_vault_uri
}

output "aks_cluster_name" {
  description = "AKS Cluster name."
  value       = module.aks.cluster_name
}

output "aks_additional_node_pools" {
  description = "Map of user node pools."
  value       = module.aks.node_pool_ids
}

output "cicd_runner_ips" {
  description = "Private IPs of CI/CD runner VMs."
  value       = module.compute_vm.vm_private_ips
}

output "private_dns_zone_ids" {
  description = "Map of Private DNS Zones."
  value       = module.private_dns.dns_zone_ids
}

output "private_endpoint_ips" {
  description = "Private IPs of PaaS Private Endpoints."
  value       = module.private_endpoints.private_ip_addresses
}
