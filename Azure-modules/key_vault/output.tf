output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "Key Vault resource ID"
}

output "key_vault_name" {
  value       = azurerm_key_vault.this.name
  description = "Key Vault name"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "Key Vault URI"
}

output "private_endpoint_id" {
  value       = var.private_endpoint_enabled ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint ID if enabled"
}