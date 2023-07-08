output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storeacc.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storeacc.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.storeacc.primary_location
}

output "primary_access_key" {
  value = azurerm_storage_account.storeacc.primary_access_key
}
output "primary_blob_endpoint" {
  value = azurerm_storage_account.storeacc.primary_blob_endpoint
}
