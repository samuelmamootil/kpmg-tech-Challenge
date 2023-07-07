data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = local.vnet_name
}


data "azurerm_subnet" "snet" {
  for_each             = toset(local.subnet_names)
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  name                 = each.value
}

module "monitor_action_groups" {
  source              = "../../modules/action_group"
  for_each            = local.monitor_action_groups
  name                = each.value.action_group_name
  settings            = each.value
  resource_group_name = each.value.resource_group_name
}

 module "vnet" {
   source              = "../../modules/vnet"
   vnet_name           = local.vnet_name
   resource_group_name = data.azurerm_resource_group.rg.name
   location            = data.azurerm_resource_group.rg.location
   address_space       = [local.vnet_address_space]
 }

 module "subnet" {
   source              = "../../modules/subnet"
   resource_group_name = data.azurerm_resource_group.rg.name
   subnet_name         = local.subnet_name
   vnet_name           = local.vnet_name
   subnet_prefix       = [local.subnet_prefix]
   nsg_name            = module.nsg.network_security_group_name
   service_endpoints   = []

   depends_on = [
     module.vnet,
     module.nsg
   ]
 }

module "nsg" {
  source              = "../../modules/nsg"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  nsg_name            = local.nsg_name
  workspace_id        = module.log_analytics.analytics_workspace_id

  nsgrules = local.nsgrules

  depends_on = [
    module.log_analytics
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each                  = data.azurerm_subnet.snet
  subnet_id                 = data.azurerm_subnet.snet[each.key].id
  network_security_group_id = module.nsg.network_security_group_id

  timeouts {
    create = "5m"
    delete = "10m"
  }

  depends_on = [
    data.azurerm_subnet.snet,
    module.nsg
  ]
}

 module "routetable" {
   source                 = "../../modules/udr"
   resource_group_name    = data.azurerm_resource_group.rg.name
   location               = data.azurerm_resource_group.rg.location
   route_table_name       = local.udr_name
   route_prefixes         = [local.subnet_prefix, "0.0.0.0/0"]
   route_nexthop_types    = ["VirtualAppliance", "VirtualAppliance"]
   next_hop_in_ip_address = ["10.194.18.4", "10.194.18.4"]
   route_names            = [local.route_name_to_hm, local.route_name_to_internet]
   subnet_ids             = [module.subnet.az_subnet_id]

   depends_on = [
     module.subnet
   ]
 }

module "log_analytics" {
  source              = "../../modules/log_analytics"
  workspace_name      = local.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  workspace_id        = module.log_analytics.analytics_workspace_id
}

module "keyvault" {
  source                  = "../../modules/keyvault"
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  key_vault_name          = local.key_vault_name
  enable_purge_protection = true #var.env_name != "prod" ? false : true
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id,
      data.azurerm_subnet.snet[local.pe_subnet_name].id
    ]
  }
  vnet_id                    = data.azurerm_virtual_network.vnet.id
  private_endpoint_subnet_id = data.azurerm_subnet.snet[local.pe_subnet_name].id
  secrets                    = {}
  workspace_id               = module.log_analytics.analytics_workspace_id

  depends_on = [
    module.log_analytics
  ]
}

module "application_insights" {
  source                     = "../../modules/application_insights"
  name                       = local.application_insights_name
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  log_analytics_workspace_id = module.log_analytics.analytics_workspace_id

  depends_on = [
    module.log_analytics
  ]
}

module "database" {
  source              = "../../modules/mssql"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  db_server_name      = local.db_server_name
  db_name             = local.db_name
  job_agent_name      = local.job_agent_name
  sku_name            = local.mssql_sku_name
  sql_collation       = local.mssql_sql_collation
  db_size             = local.mssql_db_size
  key_vault_id        = module.keyvault.key_vault_id
  workspace_name      = local.log_analytics_workspace_name
  workspace_id        = module.log_analytics.analytics_workspace_id
  ad_display_name     = local.db_server_ad_admin

  vnet_id                    = data.azurerm_virtual_network.vnet.id
  private_endpoint_subnet_id = data.azurerm_subnet.snet[local.pe_subnet_name].id

  frontend_whitelist                 = module.web_app.outbound_ip_address_list

   virtual_network_subnet_ids =  [  data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id, data.azurerm_subnet.snet[local.pe_subnet_name].id ]

  virtual_network_rules = {
    "${local.vnet_integration_subnet_name}" : {
      "subnet_id" = data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id
    }
    "${local.pe_subnet_name}" : {
      "subnet_id" = data.azurerm_subnet.snet[local.pe_subnet_name].id
    }
  }
  storage_account_network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = sort([for k, v in local.developers_zscaler : v.cidr])
    subnet_ids = [
      data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id,
      data.azurerm_subnet.snet[local.pe_subnet_name].id
    ]
  }

  storage_account_lifecycles = local.storage_account_lifecycles

  metric_alert_monitor_action_group_id = module.monitor_action_groups["metric_alerts_action_group"].id

  depends_on = [
    module.keyvault
  ]
}

#Presentation 
module "app_service_plan" {
  source                               = "../../modules/app_service_plan"
  resource_group_name                  = data.azurerm_resource_group.rg.name
  location                             = var.location
  name                                 = local.app_service_plan_name
  sku_name                             = local.app_service_plan_sku_name
  os_type                              = local.app_service_plan_os_type
  enable_autoscaling                   =  true
  metric_alert_monitor_action_group_id = module.monitor_action_groups["metric_alerts_action_group"].id
}

module "web_app" {
  source                                   = "../../modules/web_app"
  resource_group_name                      = data.azurerm_resource_group.rg.name
  location                                 = var.location
  name                                     = [local.web_app_mws_name, local.web_app_ws_name, local.web_app_jms_name]
  service_plan_id                          = module.app_service_plan.app_service_plan_id
  current_stack                            = local.web_app_current_stack
  java_version                             = local.web_app_java_version
  java_container                           = local.web_app_java_container
  java_container_version                   = local.web_app_java_container_version
  workspace_id                             = module.log_analytics.analytics_workspace_id
  private_dns_zone_vnet_id                 = data.azurerm_virtual_network.vnet.id
  private_endpoint_subnet_id               = data.azurerm_subnet.snet[local.pe_subnet_name].id
  vnet_integration_subnet_id               = data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id
  mssql_connections_string                 = module.database.azure_sql_connection_string
  application_insights_instrumentation_key = module.application_insights.instrumentation_key
  application_insights_connection_string   = module.application_insights.connection_string
  ip_restrictions                          = local.ip_restrictions
  scm_ip_restrictions                      = local.ip_restrictions_scm

  java_opts = local.web_app_java_opts

  metric_alert_monitor_action_group_id = module.monitor_action_groups["metric_alerts_action_group"].id

  depends_on = [
    module.app_service_plan
  ]
}
#Application  
module "app_service_plan" {
  source                               = "../../modules/app_service_plan"
  resource_group_name                  = data.azurerm_resource_group.rg.name
  location                             = var.location
  name                                 = local.app_service_plan_name
  sku_name                             = local.app_service_plan_sku_name
  os_type                              = local.app_service_plan_os_type
  enable_autoscaling                   = true
  metric_alert_monitor_action_group_id = module.monitor_action_groups["metric_alerts_action_group"].id
}

module "web_app" {
  source                                   = "../../modules/web_app"
  resource_group_name                      = data.azurerm_resource_group.rg.name
  location                                 = var.location
  name                                     = [local.web_app_mws_name, local.web_app_ws_name, local.web_app_jms_name]
  service_plan_id                          = module.app_service_plan.app_service_plan_id
  current_stack                            = local.web_app_current_stack
  java_version                             = local.web_app_java_version
  java_container                           = local.web_app_java_container
  java_container_version                   = local.web_app_java_container_version
  workspace_id                             = module.log_analytics.analytics_workspace_id
  private_dns_zone_vnet_id                 = data.azurerm_virtual_network.vnet.id
  private_endpoint_subnet_id               = data.azurerm_subnet.snet[local.pe_subnet_name].id
  vnet_integration_subnet_id               = data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id
  mssql_connections_string                 = module.database.azure_sql_connection_string
  application_insights_instrumentation_key = module.application_insights.instrumentation_key
  application_insights_connection_string   = module.application_insights.connection_string
  ip_restrictions                          = local.ip_restrictions
  scm_ip_restrictions                      = local.ip_restrictions_scm

  java_opts = local.web_app_java_opts

  metric_alert_monitor_action_group_id = module.monitor_action_groups["metric_alerts_action_group"].id

  depends_on = [
    module.app_service_plan
  ]
}

module "web_app_staging_slot" {
  source                                   = "../../modules/web_app_slot"
  name                                     = "staging"
  resource_group_name                      = data.azurerm_resource_group.rg.name
  location                                 = var.location
  app_service_ids                          = module.web_app.id
  current_stack                            = local.web_app_current_stack
  java_version                             = local.web_app_java_version
  java_container                           = local.web_app_java_container
  java_container_version                   = local.web_app_java_container_version
  workspace_id                             = module.log_analytics.analytics_workspace_id
  private_dns_zone_vnet_id                 = data.azurerm_virtual_network.vnet.id
  private_endpoint_subnet_id               = data.azurerm_subnet.snet[local.pe_subnet_name].id
  vnet_integration_subnet_id               = data.azurerm_subnet.snet[local.vnet_integration_subnet_name].id
  mssql_connections_string                 = module.database.azure_sql_connection_string
  application_insights_instrumentation_key = module.application_insights.instrumentation_key
  application_insights_connection_string   = module.application_insights.connection_string
  ip_restrictions                          = local.ip_restrictions
  scm_ip_restrictions                      = local.ip_restrictions_scm

  java_opts = local.web_app_java_opts

  depends_on = [
    module.web_app
  ]
}
