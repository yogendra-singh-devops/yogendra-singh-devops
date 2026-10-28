output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their Key Vault Secret IDs."
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.id }
}

