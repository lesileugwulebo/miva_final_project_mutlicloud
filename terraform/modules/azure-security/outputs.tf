output "web_nsg_id" {
  value       = azurerm_network_security_group.web.id
  description = "The ID of the Web Network Security Group"
}

output "app_nsg_id" {
  value       = azurerm_network_security_group.app.id
  description = "The ID of the App Network Security Group"
}

output "db_nsg_id" {
  value       = azurerm_network_security_group.db.id
  description = "The ID of the DB Network Security Group"
}

output "mgmt_nsg_id" {
  value       = azurerm_network_security_group.mgmt.id
  description = "The ID of the Mgmt Network Security Group"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.vault.vault_uri
  description = "The URI of the Azure Key Vault"
}

output "workload_identity_client_id" {
  value       = azurerm_user_assigned_identity.workload_identity.client_id
  description = "The Client ID of the Workload Identity"
}

output "workload_identity_principal_id" {
  value       = azurerm_user_assigned_identity.workload_identity.principal_id
  description = "The Principal ID of the Workload Identity"
}
