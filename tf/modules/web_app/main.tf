resource "azurerm_windows_web_app" "wa" {
  for_each            = toset(var.name)
  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan_id

  https_only              = true
  client_affinity_enabled = true

  site_config {
    health_check_path                       = contains(split("-", each.value), "web") ? "/index.html" : null
    http2_enabled          = true
    always_on              = true
    vnet_route_all_enabled = true
    ftps_state             = "Disabled"
    minimum_tls_version    = "1.2"
    websockets_enabled     = true

    application_stack {
      current_stack          = var.current_stack
      java_version           = var.java_version
      java_container         = var.java_container
      java_container_version = var.java_container_version
    }

    ip_restriction = lookup(var.ip_restrictions, each.key, null) == null ? null : lookup(var.ip_restrictions, each.key, null)
    # dynamic "ip_restriction" {
    #   for_each = lookup(var.ip_restrictions, each.key, null) #var.ip_restrictions[each.key]
    #   iterator = ip_restriction
    #   content {
    #     headers                   = ip_restriction.value.headers
    #     ip_address                = ip_restriction.value.ip_address
    #     name                      = ip_restriction.value.name
    #     priority                  = ip_restriction.value.priority
    #     service_tag               = ip_restriction.value.service_tag
    #     virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
    #   }
    # }

    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

    scm_ip_restriction = lookup(var.scm_ip_restrictions, each.key, null) == null ? null : lookup(var.scm_ip_restrictions, each.key, null)
    # dynamic "scm_ip_restriction" {
    #   for_each = lookup(var.ip_restrictions, each.key, null) #var.ip_restrictions[each.key]
    #   iterator = scm_ip_restriction
    #   content {
    #     headers                   = scm_ip_restriction.value.headers
    #     ip_address                = scm_ip_restriction.value.ip_address
    #     name                      = scm_ip_restriction.value.name
    #     priority                  = scm_ip_restriction.value.priority
    #     service_tag               = scm_ip_restriction.value.service_tag
    #     virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
    #   }
    # }
  }

  app_settings = {
    "JAVA_OPTS"                                  = var.java_opts
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.application_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
    "APPLICATIONINSIGHTS_ROLE_NAME"              = each.key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_Java"      = "1"
    "XDT_MicrosoftApplicationInsights_Mode"      = "default"
    # "APPLICATIONINSIGHTS_SELF_DIAGNOSTICS_LEVEL" = "debug"
    #"WEBSITE_VNET_ROUTE_ALL" = 1
    # "WEBSITE_DNS_SERVER" = "168.63.129.16"
    # "WEBSITE_DNS_ALT_SERVER" = "10.194.18.100"
  }

  connection_string {
    name  = "CONNECTION_STRING"
    type  = "SQLAzure"
    value = var.mssql_connections_string
  }


  logs {
    detailed_error_messages = true
    failed_request_tracing  = false

    application_logs {
      file_system_level = "Error"
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

module "wa_diagnostics_settings" {
  #count = length(var.name)
  for_each           = toset(var.name)
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_windows_web_app.wa[each.value].id
  workspace_id       = var.workspace_id

  depends_on = [
    azurerm_windows_web_app.wa
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integration" {
  for_each       = toset(var.name)
  app_service_id = azurerm_windows_web_app.wa[each.value].id
  subnet_id      = var.vnet_integration_subnet_id

  depends_on = [
    azurerm_windows_web_app.wa
  ]
}

module "metric_alerts" {
  for_each                             = azurerm_windows_web_app.wa
  source                               = "../../modules/web_app_metric_alerts"
  resource_name                        = each.value.name
  resource_id                          = each.value.id
  metric_alert_monitor_action_group_id = var.metric_alert_monitor_action_group_id
  resource_group_name                  = var.resource_group_name
}

# module "private_dns_zone" {
#   source                          = "../private_dns_zone"
#   resource_group_name             = var.resource_group_name
#   private_dns_zone_name           = "privatelink.azurewebsites.net"
#   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_webapp"
#   vnet_id                         = var.private_dns_zone_vnet_id
# }

# module "private_endpoint" {
#   for_each = toset(var.name)
#   source                          = "../private_endpoint"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   name                            = "${azurerm_windows_web_app.wa[each.value].name}-priv-endpoint"
#   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
#   private_service_connection_name = "${azurerm_windows_web_app.wa[each.value].name}-priv-serv-con"
#   endpoint_resource_id            = azurerm_windows_web_app.wa[each.value].id
#   private_dns_zone_name           = module.private_dns_zone.private_dns_zone_name
#   subresource_names               = ["sites"]

#   depends_on = [
#     module.private_dns_zone,
#     azurerm_windows_web_app.wa
#   ]
# }

# data "azurerm_private_endpoint_connection" "pe_conn" {
#   for_each = toset(var.name)
#   name                = "${azurerm_windows_web_app.wa[each.value].name}-priv-endpoint"
#   resource_group_name = var.resource_group_name
#   depends_on          = [module.private_endpoint]
# }

# resource "azurerm_private_dns_a_record" "a_record" {
#   for_each = toset(var.name)
#   name                = each.value
#   zone_name           = "privatelink.azurewebsites.net"
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [data.azurerm_private_endpoint_connection.pe_conn[each.value].private_service_connection.0.private_ip_address]


#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_private_dns_a_record" "a_record_scm" {
#   for_each = toset(var.name)
#   name                = "${each.value}.scm"
#   zone_name           = "privatelink.azurewebsites.net"
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [data.azurerm_private_endpoint_connection.pe_conn[each.value].private_service_connection.0.private_ip_address]


#   lifecycle {
#     ignore_changes = [tags]
#   }
# }