resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each            = var.metric_alerts
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