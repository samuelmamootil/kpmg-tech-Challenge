locals {
  resource_group_name                    = "rg-${var.app_name}-${var.short_location}-${var.env_name}-001"
  key_vault_name                         = "kv-${var.app_name}-${var.short_location}-${var.env_name}-001"
  nsg_name                               = "nsg-${var.app_name}-${var.short_location}-${var.env_name}-001"
  vnet_name                              = "vnet-${var.app_name}-${var.short_location}-${var.env_name}-001"

  pe_subnet_name               = "snet-${var.app_name}-${var.short_location}-${var.env_name}-001"
  vnet_integration_subnet_name = "snet-${var.app_name}-${var.short_location}-${var.env_name}-002"
  subnet_names                 = [local.pe_subnet_name, local.vnet_integration_subnet_name]
  subnet_prefix                = "10.0.0.0/27"
 

  app_service_plan_name = "plan-${var.app_name}-${var.short_location}-${var.env_name}-001"
  app_service_plan_name2 = "plan-${var.app_name}-${var.short_location}-${var.env_name}-002"

  web_app_name = "app-${var.app_name}-web-${var.short_location}-${var.env_name}-001"
  web_app_name2 = "app-${var.app_name}-web-${var.short_location}-${var.env_name}-002"
  web_app_ws_name  = "app-${var.app_name}-ws-${var.short_location}-${var.env_name}-001"
  web_app_jms_name = "app-${var.app_name}-jms-${var.short_location}-${var.env_name}-001"

  db_server_name     = "sql-${var.app_name}-${var.short_location}-${var.env_name}-001"
  db_server_ad_admin = "administrator"
  db_name            = "sqldb-${var.app_name}-${var.short_location}-${var.env_name}-001"
  job_agent_name     = "sqldbej-${var.app_name}-${var.short_location}-${var.env_name}-001"

  udr_name               = "udr-${var.app_name}-${var.short_location}-${var.env_name}-001"
  route_name_to_hm       = "${local.vnet_name}-to-all-spoke-and-hm-001"
  route_name_to_internet = "${local.vnet_name}-to-internet"

  mssql_sku_name      = "S4"
  mssql_sql_collation = "Latin1_General_100_BIN2_UTF8"
  mssql_db_size       = "250"

  app_service_plan_sku_name      = "S1"
  app_service_plan_os_type       = "Windows"
  web_app_current_stack          = "java"
  web_app_java_version           = "11"
  web_app_java_container         = "TOMCAT"
  web_app_java_container_version = "9.0"

  web_app_java_opts = "-Denvironment=test -verbose:class"

  monitor_action_groups = {
    action_group_value = {
      action_group_name   = "ag${var.env_name}${var.app_name}1"
      resource_group_name = local.resource_group_name
      shortname           = "ag${var.env_name}${var.app_name}1" #only 12 characters allowed
      email_receiver = {
        email_alert1 = {
          name                    = "Azure Alert for ${var.env_name} Environment"
          email_address           = "DLBTCustInspireandDiscoverContentCreationandAutomation@hm.com"
          use_common_alert_schema = true
        }
      }
    }
    metric_alerts_action_group = {
      action_group_name   = "ag${var.env_name}${var.app_name}2"
      resource_group_name = local.resource_group_name
      shortname           = "ag${var.env_name}${var.app_name}2" #only 12 characters allowed
      email_receiver = {
        email_alert1 = {
          name                    = "Azure Metric Alert for ${var.env_name} Environment"
          email_address           = "1c84e82d.hm.com@emea.teams.ms"
          use_common_alert_schema = true
        }
      }
    }
  } 

  nsgrules = [
     {
      access                     = "Allow"
      description                = ""
      destination_address_prefix = "Sql.WestEurope"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range = ""
      destination_port_ranges                    = ["1433", "11000-11999"]
      direction             = "Outbound"
      name                  = "AllowSqlWeOutBound"
      priority              = 140
      protocol              = "Tcp"
      source_address_prefix = "VirtualNetwork"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range = "*"
      source_port_ranges                         = []
    },
    {
      access                     = "Allow"
      description                = ""
      destination_address_prefix = "Storage.WestEurope"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range = "443"
      destination_port_ranges                    = []
      direction             = "Outbound"
      name                  = "AllowStorageWeOutBound"
      priority              = 150
      protocol              = "Tcp"
      source_address_prefix = "VirtualNetwork"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range = "*"
      source_port_ranges                         = []
    },
    {
      access                     = "Allow"
      description                = ""
      destination_address_prefix = "AzureMonitor"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range = "443"
      destination_port_ranges                    = []
      direction             = "Outbound"
      name                  = "AllowAzureMonitorOutBound"
      priority              = 160
      protocol              = "Tcp"
      source_address_prefix = "VirtualNetwork"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range = "*"
      source_port_ranges                         = []
    },
    {
      access                     = "Deny"
      description                = ""
      destination_address_prefix = "Internet"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range     = "*"
      destination_port_ranges                    = []
      direction                  = "Outbound"
      name                       = "DenyInternetOutBound"
      priority                   = 170
      protocol                   = "*"
      source_address_prefix      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range          = "*"
      source_port_ranges                         = []
    },

    {
      access                     = "Allow"
      description                = ""
      destination_address_prefix = "VirtualNetwork"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range = "443"
      destination_port_ranges                    = []
      direction             = "Inbound"
      name                  = "AllowSqlWeInBound"
      priority              = 140
      protocol              = "Tcp"
      source_address_prefix = "Sql.WestEurope"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range = "*"
      source_port_ranges                         = []
    }
  ]

  storage_account_lifecycles = [
    {
      rule_name                  = "DeleteAfter30Days"
      prefix_match               = [""]
      tier_to_cool_after_days    = -1
      tier_to_archive_after_days = -1
      delete_after_days          = 30
      snapshot_delete_after_days = 30
    }
  ]

  ip_restrictions = {
    "${local.web_app_mws_name}" = [
      for k, v in local.users_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
    "${local.web_app_jms_name}" = [
      for k, v in local.developers_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
    "${local.web_app_ws_name}" = [
      for k, v in local.developers_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
  }
  ip_restrictions_scm = {
    "${local.web_app_mws_name}" = [
      for k, v in local.users_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
    "${local.web_app_jms_name}" = [
      for k, v in local.developers_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
    "${local.web_app_ws_name}" = [
      for k, v in local.developers_zscaler :
      {
        action                    = "Allow"
        headers                   = null
        ip_address                = v.cidr
        name                      = format("%s%s", "Allow", split("-", k)[0])
        priority                  = join("", [10, index(keys(local.users_zscaler), k), 0])
        service_tag               = null
        virtual_network_subnet_id = null
      }
    ]
  }

  storage_account_network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = [for k, v in local.developers_zscaler : v.cidr]
    virtual_network_subnet_ids = []
  }
}

# locals {
#   frontend_whitelist = {
#       for ip in distinct(flatten(var.frontend_whitelist)):
#          format("%s-%s", "frontend", ip) => {ip_address = ip}
#   }
# }
