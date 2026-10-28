output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  description = "The Name of the Storage Account."
  value       = azurerm_storage_account.sa.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL."
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "principal_id" {
  description = "The Principal ID of the system-assigned managed identity."
  value       = azurerm_storage_account.sa.identity[0].principal_id
}

output "container_ids" {
  description = "Map of container names to their resource IDs."
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}

