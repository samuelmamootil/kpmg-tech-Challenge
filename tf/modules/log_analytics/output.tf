output "analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.analytics_workspace.id
}

output "analytics_workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.analytics_workspace.primary_shared_key
  sensitive = true
}

output "analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.analytics_workspace.name
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.analytics_workspace.workspace_id
}