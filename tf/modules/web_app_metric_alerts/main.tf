locals {
  alerts = {
    "${var.resource_name}-AverageMemory" : {
      auto_mitigate       = true
      description         = "AppService-AverageMemory"
      enabled             = true
      frequency           = "PT5M"
      resource_group_name = var.resource_group_name
      scopes              = [var.resource_id]
      severity            = 3

      target_resource_location = "westeurope"
      target_resource_type     = "Microsoft.Web/sites"
      window_size              = "PT30M"


      action__action_group_id          = var.metric_alert_monitor_action_group_id
      criteria__aggregation            = "Average"
      criteria__metric_name            = "AverageMemoryWorkingSet"
      criteria__metric_namespace       = "Microsoft.Web/sites"
      criteria__operator               = "GreaterThan"
      criteria__skip_metric_validation = false
      criteria__threshold              = contains(split("-", var.resource_group_name), "prod") ? 5000000000 : 1500000000
    }
    "${var.resource_name}-DataIn" : {
      auto_mitigate       = true
      description         = "AppService-The amount of incoming bandwidth consumed by the app"
      enabled             = true
      frequency           = "PT5M"
      resource_group_name = var.resource_group_name
      scopes              = [var.resource_id]
      severity            = 3

      target_resource_type = "Microsoft.Web/sites"
      window_size          = "PT30M"


      action__action_group_id          = var.metric_alert_monitor_action_group_id
      criteria__aggregation            = "Average"
      criteria__metric_name            = "BytesReceived"
      criteria__metric_namespace       = "Microsoft.Web/sites"
      criteria__operator               = "GreaterThan"
      criteria__skip_metric_validation = false
      criteria__threshold              = 67108880
    }
    "${var.resource_name}-DataOut" : {
      auto_mitigate       = true
      description         = "The amount of outgoing bandwidth consumed by the app"
      enabled             = true
      frequency           = "PT5M"
      resource_group_name = var.resource_group_name
      scopes              = [var.resource_id]
      severity            = 3

      target_resource_type = "Microsoft.Web/sites"
      window_size          = "PT30M"


      action__action_group_id          = var.metric_alert_monitor_action_group_id
      criteria__aggregation            = "Average"
      criteria__metric_name            = "BytesSent"
      criteria__metric_namespace       = "Microsoft.Web/sites"
      criteria__operator               = "GreaterThan"
      criteria__skip_metric_validation = false
      criteria__threshold              = 100000000
    }
    "${var.resource_name}-ClientErrors" : {
      auto_mitigate       = true
      description         = "The count of requests resulting in an HTTP status code ≥ 400 but < 500"
      enabled             = true
      frequency           = "PT5M"
      resource_group_name = var.resource_group_name
      scopes              = [var.resource_id]
      severity            = 3

      target_resource_location = "westeurope"
      target_resource_type     = "Microsoft.Web/sites"
      window_size              = "PT30M"


      action__action_group_id          = var.metric_alert_monitor_action_group_id
      criteria__aggregation            = "Count"
      criteria__metric_name            = "Http4xx"
      criteria__metric_namespace       = "Microsoft.Web/sites"
      criteria__operator               = "GreaterThan"
      criteria__skip_metric_validation = false
      criteria__threshold              = 10
    }
    "${var.resource_name}-ServerErrors" : {
      auto_mitigate       = true
      description         = "The count of requests resulting in an HTTP status code ≥ 500 but < 600"
      enabled             = true
      frequency           = "PT5M"
      resource_group_name = var.resource_group_name
      scopes              = [var.resource_id]
      severity            = 3

      target_resource_type = "Microsoft.Web/sites"
      window_size          = "PT30M"


      action__action_group_id          = var.metric_alert_monitor_action_group_id
      criteria__aggregation            = "Count"
      criteria__metric_name            = "Http5xx"
      criteria__metric_namespace       = "Microsoft.Web/sites"
      criteria__operator               = "GreaterThan"
      criteria__skip_metric_validation = false
      criteria__threshold              = 10
    }
  }
}


resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each            = local.alerts
  auto_mitigate       = each.value.auto_mitigate
  description         = each.value.description
  enabled             = each.value.enabled
  frequency           = each.value.frequency
  name                = each.key
  resource_group_name = each.value.resource_group_name
  scopes              = each.value.scopes
  severity            = each.value.severity

  target_resource_type = each.value.target_resource_type
  window_size          = each.value.window_size

  action {
    action_group_id = each.value.action__action_group_id
    # webhook_properties = {}
  }

  criteria {
    aggregation            = each.value.criteria__aggregation
    metric_name            = each.value.criteria__metric_name
    metric_namespace       = each.value.criteria__metric_namespace
    operator               = each.value.criteria__operator
    skip_metric_validation = each.value.criteria__skip_metric_validation
    threshold              = each.value.criteria__threshold
  }


  lifecycle {
    ignore_changes = [tags]
  }
}