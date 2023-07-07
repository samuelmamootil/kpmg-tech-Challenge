resource "azurerm_application_insights" "appinsights" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  application_type    = var.application_type

  lifecycle {
    ignore_changes = [tags]
  }
}

module "application_insights_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_application_insights.appinsights.id
  workspace_id       = var.log_analytics_workspace_id
}