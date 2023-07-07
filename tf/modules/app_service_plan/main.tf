resource "azurerm_service_plan" "sp" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  os_type             = var.os_type

  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "${var.name}-AutoscaleSetting"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.sp.id
  profile {
    name = "${var.name}-profile-001"
    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }
    rule {
      metric_trigger {
        metric_namespace         = "microsoft.web/serverfarms"
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_namespace         = "microsoft.web/serverfarms"
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 85
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    azurerm_service_plan.sp
  ]
}

module "metric_alerts" {
  source = "../../modules/app_service_plan_metric_alerts"

  resource_name                        = azurerm_service_plan.sp.name
  resource_id                          = azurerm_service_plan.sp.id
  metric_alert_monitor_action_group_id = var.metric_alert_monitor_action_group_id
  resource_group_name                  = var.resource_group_name
}

