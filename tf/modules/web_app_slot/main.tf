resource "azurerm_windows_web_app_slot" "web_app_slot" {
  for_each       = var.app_service_ids
  name           = var.name
  app_service_id = each.value.id

  https_only              = true
  client_affinity_enabled = true

  site_config {
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
    #   for_each = var.ip_restrictions[each.key]
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
    scm_ip_restriction = lookup(var.scm_ip_restrictions, each.key, null) == null ? null : lookup(var.scm_ip_restrictions, each.key, null)
  }


  app_settings = {
    "JAVA_OPTS"                                  = var.java_opts
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.application_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
    "APPLICATIONINSIGHTS_ROLE_NAME"              = "${var.name} (${each.key})"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_Java"      = "1"
    "XDT_MicrosoftApplicationInsights_Mode"      = "default"
    #"WEBSITE_VNET_ROUTE_ALL" = 1
    # "WEBSITE_DNS_SERVER" = "168.63.129.16"
    # "WEBSITE_DNS_ALT_SERVER" = "10.194.18.100"
  }

  connection_string {
    name  = "CONNECTION_STRING" #SQLAZURECONNSTR_sqldb-mws-we-acc-001
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

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_service_slot_vnet_integration" {
  for_each       = var.app_service_ids
  slot_name      = var.name
  app_service_id = each.value.id
  subnet_id      = var.vnet_integration_subnet_id

  depends_on = [
    azurerm_windows_web_app_slot.web_app_slot
  ]
}

module "wa_diagnostics_settings" {
  #count = length(var.name)
  for_each           = var.app_service_ids
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_windows_web_app_slot.web_app_slot[each.key].id
  workspace_id       = var.workspace_id

  depends_on = [
    azurerm_windows_web_app_slot.web_app_slot
  ]
}

 module "private_dns_zone" {
   source                          = "../private_dns_zone"
   resource_group_name             = var.resource_group_name
   private_dns_zone_name           = "privatelink.azurewebsites.net"
   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_webapp"
   vnet_id                         = var.private_dns_zone_vnet_id
 }

 module "private_endpoint" {
   for_each = var.app_service_ids
   source                          = "../private_endpoint"
   resource_group_name             = var.resource_group_name
   location                        = var.location
   name                            = "${each.key}-${azurerm_windows_web_app_slot.web_app_slot[each.key].name}-priv-endpoint"
   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
   private_service_connection_name = "${each.key}-${azurerm_windows_web_app_slot.web_app_slot[each.key].name}-priv-serv-con"
   endpoint_resource_id            = each.value.id #azurerm_windows_web_app_slot.web_app_slot[each.key].id
   private_dns_zone_name           = "privatelink.azurewebsites.net"
   subresource_names               = ["sites-staging"]
 }