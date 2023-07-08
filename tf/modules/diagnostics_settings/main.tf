data "azurerm_monitor_diagnostic_categories" "diagnostic_categories" {
  resource_id = var.target_resource_id
}

locals {
  resource_type = element(split("/", var.target_resource_id), length(split("/", var.target_resource_id)) - 2)
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  name                       = "${local.resource_type}-diagnostics"
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.workspace_id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories.logs

    content {
      category = log.key
      enabled  = true

      retention_policy {
        days    = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories.metrics

    content {
      category = metric.key
      enabled  = true

      retention_policy {
        days    = 30
        enabled = true
      }
    }
  }

  lifecycle {
    ignore_changes = [metric, log]
  }
}
