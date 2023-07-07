resource "azurerm_log_analytics_workspace" "analytics_workspace" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  lifecycle {
    ignore_changes = [tags]
  }
}

module "log_analytics_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_log_analytics_workspace.analytics_workspace.id
  workspace_id       = var.workspace_id
  depends_on = [
    azurerm_log_analytics_workspace.analytics_workspace
  ]
}

