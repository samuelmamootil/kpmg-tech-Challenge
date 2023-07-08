locals {
  resource_group_name                    = "rg-${var.app_name}-${var.short_location}-${var.env_name}-001"
  key_vault_name                         = "kv-${var.app_name}-${var.short_location}-${var.env_name}-001"
  nsg_name                               = "nsg-${var.app_name}-${var.short_location}-${var.env_name}-001"
  vnet_name                              = "vnet-${var.app_name}-${var.short_location}-${var.env_name}-001"

  pe_subnet_name               = "snet-${var.app_name}-${var.short_location}-${var.env_name}-001"
  vnet_integration_subnet_name = "snet-${var.app_name}-${var.short_location}-${var.env_name}-002"
  subnet_names                 = [local.pe_subnet_name, local.vnet_integration_subnet_name]
  subnet_prefix                = "10.194.148.64/27"
 

  app_service_plan_name = "plan-${var.app_name}-${var.short_location}-${var.env_name}-001"
  app_service_plan_name2 = "plan-${var.app_name}-${var.short_location}-${var.env_name}-002"

  web_app_name = "app-${var.app_name}-web-${var.short_location}-${var.env_name}-001"
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

  

  developers_zscaler = {
    "ZScalerChennai-165.225.104.0-24" : { "cidr" = "165.225.104.0/24",
      "end"                                      = "165.225.104.254",
    "start" = "165.225.104.1" },
    "ZScalerChennaiII-165.225.122.0-23" : { "cidr" = "165.225.122.0/23",
      "end"                                        = "165.225.123.254",
    "start" = "165.225.122.1" },
    "ZScalerAmsterdamII-147.161.172.0-23" : { "cidr" = "147.161.172.0/23",
      "end"                                          = "147.161.173.254",
    "start" = "147.161.172.1" },
    "ZScalerAmsterdamII-185.46.212.0-23" : { "cidr" = "185.46.212.0/23",
      "end"                                         = "185.46.213.254",
    "start" = "185.46.212.1" },
    "ZScalerAmsterdamII-165.225.240.0-23" : { "cidr" = "165.225.240.0/23",
      "end"                                          = "165.225.241.254",
    "start" = "165.225.240.1" }
  }


  users_zscaler = {
    "ZScalerAuckland-124.248.141.0-24" : { "cidr" = "124.248.141.0/24",
      "end"                                       = "124.248.141.254",
    "start" = "124.248.141.1" },
    "ZScalerBeijing-211.144.19.0-24" : { "cidr" = "211.144.19.0/24",
      "end"                                     = "211.144.19.254",
    "start" = "211.144.19.1" },
    "ZScalerChennai-165.225.104.0-24" : { "cidr" = "165.225.104.0/24",
      "end"                                      = "165.225.104.254",
    "start" = "165.225.104.1" },
    "ZScalerChennaiII-165.225.122.0-23" : { "cidr" = "165.225.122.0/23",
      "end"                                        = "165.225.123.254",
    "start" = "165.225.122.1" },
    "ZScalerHongKongIII-165.225.116.0-23" : { "cidr" = "165.225.116.0/23",
      "end"                                          = "165.225.117.254",
    "start" = "165.225.116.1" },
    "ZScalerHongKongIII-165.225.234.0-23" : { "cidr" = "165.225.234.0/23",
      "end"                                          = "165.225.235.254",
    "start" = "165.225.234.1" },
    "ZScalerMelbourneII-165.225.226.0-23" : { "cidr" = "165.225.226.0/23",
      "end"                                          = "165.225.227.254",
    "start" = "165.225.226.1" },
    "ZScalerMelbourneII-147.161.212.0-23" : { "cidr" = "147.161.212.0/23",
      "end"                                          = "147.161.213.254",
    "start" = "147.161.212.1" },
    "ZScalerMumbaiIV-165.225.106.0-23" : { "cidr" = "165.225.106.0/23",
      "end"                                       = "165.225.107.254",
    "start" = "165.225.106.1" },
    "ZScalerMumbaiVI-165.225.120.0-23" : { "cidr" = "165.225.120.0/23",
      "end"                                       = "165.225.121.254",
    "start" = "165.225.120.1" },
    "ZScalerNewDelhiI-165.225.124.0-23" : { "cidr" = "165.225.124.0/23",
      "end"                                        = "165.225.125.254",
    "start" = "165.225.124.1" },
    "ZScalerOsakaI-147.161.192.0-23" : { "cidr" = "147.161.192.0/23",
      "end"                                     = "147.161.193.254",
    "start" = "147.161.192.1" },
    "ZScalerOsakaI-147.161.194.0-23" : { "cidr" = "147.161.194.0/23",
      "end"                                     = "147.161.195.254",
    "start" = "147.161.194.1" },
    "ZScalerSeoulI-165.225.228.0-23" : { "cidr" = "165.225.228.0/23",
      "end"                                     = "165.225.229.254",
    "start" = "165.225.228.1" },
    "ZScalerShanghai-58.220.95.0-24" : { "cidr" = "58.220.95.0/24",
      "end"                                     = "58.220.95.254",
    "start" = "58.220.95.1" },
    "ZScalerSingaporeIV-165.225.112.0-23" : { "cidr" = "165.225.112.0/23",
      "end"                                          = "165.225.113.254",
    "start" = "165.225.112.1" },
    "ZScalerSingaporeIV-165.225.230.0-23" : { "cidr" = "165.225.230.0/23",
      "end"                                          = "165.225.231.254",
    "start" = "165.225.230.1" },
    "ZScalerSydneyIII-165.225.114.0-23" : { "cidr" = "165.225.114.0/23",
      "end"                                        = "165.225.115.254",
    "start" = "165.225.114.1" },
    "ZScalerSydneyIII-165.225.232.0-23" : { "cidr" = "165.225.232.0/23",
      "end"                                        = "165.225.233.254",
    "start" = "165.225.232.1" },
    "ZScalerTaipei-165.225.102.0-24" : { "cidr" = "165.225.102.0/24",
      "end"                                     = "165.225.102.254",
    "start" = "165.225.102.1" },
    "ZScalerTianjin-221.122.91.0-24" : { "cidr" = "221.122.91.0/24",
      "end"                                     = "221.122.91.254",
    "start" = "221.122.91.1" },
    "ZScalerTokyoIV-165.225.110.0-23" : { "cidr" = "165.225.110.0/23",
      "end"                                      = "165.225.111.254",
    "start" = "165.225.110.1" },
    "ZScalerTokyoIV-165.225.96.0-23" : { "cidr" = "165.225.96.0/23",
      "end"                                     = "165.225.97.254",
    "start" = "165.225.96.1" },
    "ZScalerAtlantaII-104.129.206.0-23" : { "cidr" = "104.129.206.0/23",
      "end"                                        = "104.129.207.254",
    "start" = "104.129.206.1" },
    "ZScalerBostonI-136.226.70.0-23" : { "cidr" = "136.226.70.0/23",
      "end"                                     = "136.226.71.254",
    "start" = "136.226.70.1" },
    "ZScalerBostonI-136.226.72.0-23" : { "cidr" = "136.226.72.0/23",
      "end"                                     = "136.226.73.254",
    "start" = "136.226.72.1" },
    "ZScalerBostonI-136.226.74.0-23" : { "cidr" = "136.226.74.0/23",
      "end"                                     = "136.226.75.254",
    "start" = "136.226.74.1" },
    "ZScalerChicago-165.225.0.0-23" : { "cidr" = "165.225.0.0/23",
      "end"                                    = "165.225.1.254",
    "start" = "165.225.0.1" },
    "ZScalerChicago-165.225.56.0-22" : { "cidr" = "165.225.56.0/22",
      "end"                                     = "165.225.59.254",
    "start" = "165.225.56.1" },
    "ZScalerChicago-165.225.60.0-22" : { "cidr" = "165.225.60.0/22",
      "end"                                     = "165.225.63.254",
    "start" = "165.225.60.1" },
    "ZScalerDallasI-165.225.216.0-23" : { "cidr" = "165.225.216.0/23",
      "end"                                      = "165.225.217.254",
    "start" = "165.225.216.1" },
    "ZScalerDallasI-165.225.34.0-23" : { "cidr" = "165.225.34.0/23",
      "end"                                     = "165.225.35.254",
    "start" = "165.225.34.1" },
    "ZScalerDallasI-165.225.32.0-23" : { "cidr" = "165.225.32.0/23",
      "end"                                     = "165.225.33.254",
    "start" = "165.225.32.1" },
    "ZScalerDenverIII-165.225.10.0-23" : { "cidr" = "165.225.10.0/23",
      "end"                                       = "165.225.11.254",
    "start" = "165.225.10.1" },
    "ZScalerLosAngeles-104.129.198.0-23" : { "cidr" = "104.129.198.0/23",
      "end"                                         = "104.129.199.254",
    "start" = "104.129.198.1" },
    "ZScalerMexicoCityI-136.226.0.0-23" : { "cidr" = "136.226.0.0/23",
      "end"                                        = "136.226.1.254",
    "start" = "136.226.0.1" },
    "ZScalerMiamiIII-165.225.222.0-23" : { "cidr" = "165.225.222.0/23",
      "end"                                       = "165.225.223.254",
    "start" = "165.225.222.1" },
    "ZScalerMontrealI-165.225.212.0-23" : { "cidr" = "165.225.212.0/23",
      "end"                                        = "165.225.213.254",
    "start" = "165.225.212.1" },
    "ZScalerNewYorkIII-165.225.38.0-23" : { "cidr" = "165.225.38.0/23",
      "end"                                        = "165.225.39.254",
    "start" = "165.225.38.1" },
    "ZScalerNewYorkIII-165.225.220.0-23" : { "cidr" = "165.225.220.0/23",
      "end"                                         = "165.225.221.254",
    "start" = "165.225.220.1" },
    "ZScalerNuevoLaredoI-165.225.218.0-23" : { "cidr" = "165.225.218.0/23",
      "end"                                           = "165.225.219.254",
    "start" = "165.225.218.1" },
    "ZScalerSanFranciscoIV-104.129.202.0-23" : { "cidr" = "104.129.202.0/23",
      "end"                                             = "104.129.203.254",
    "start" = "104.129.202.1" },
    "ZScalerSanFranciscoIV-165.225.242.0-23" : { "cidr" = "165.225.242.0/23",
      "end"                                             = "165.225.243.254",
    "start" = "165.225.242.1" },
    "ZScalerSaoPaulo-64.215.22.0-24" : { "cidr" = "64.215.22.0/24",
      "end"                                     = "64.215.22.254",
    "start" = "64.215.22.1" },
    "ZScalerSaoPauloII-165.225.214.0-23" : { "cidr" = "165.225.214.0/23",
      "end"                                         = "165.225.215.254",
    "start" = "165.225.214.1" },
    "ZScalerSaoPauloIV-147.161.128.0-23" : { "cidr" = "147.161.128.0/23",
      "end"                                         = "147.161.129.254",
    "start" = "147.161.128.1" },
    "ZScalerSeattle-136.226.54.0-23" : { "cidr" = "136.226.54.0/23",
      "end"                                     = "136.226.55.254",
    "start" = "136.226.54.1" },
    "ZScalerSeattle-165.225.50.0-23" : { "cidr" = "165.225.50.0/23",
      "end"                                     = "165.225.51.254",
    "start" = "165.225.50.1" },
    "ZScalerSeattle-136.226.56.0-23" : { "cidr" = "136.226.56.0/23",
      "end"                                     = "136.226.57.254",
    "start" = "136.226.56.1" },
    "ZScalerTorontoIII-165.225.208.0-23" : { "cidr" = "165.225.208.0/23",
      "end"                                         = "165.225.209.254",
    "start" = "165.225.208.1" },
    "ZScalerVancouverI-165.225.210.0-23" : { "cidr" = "165.225.210.0/23",
      "end"                                         = "165.225.211.254",
    "start" = "165.225.210.1" },
    "ZScalerWashingtonDC-104.129.194.0-23" : { "cidr" = "104.129.194.0/23",
      "end"                                           = "104.129.195.254",
    "start" = "104.129.194.1" },
    "ZScalerWashingtonDC-136.226.48.0-23" : { "cidr" = "136.226.48.0/23",
      "end"                                          = "136.226.49.254",
    "start" = "136.226.48.1" },
    "ZScalerWashingtonDC-165.225.8.0-23" : { "cidr" = "165.225.8.0/23",
      "end"                                         = "165.225.9.254",
    "start" = "165.225.8.1" },
    "ZScalerWashingtonDC-136.226.50.0-23" : { "cidr" = "136.226.50.0/23",
      "end"                                          = "136.226.51.254",
    "start" = "136.226.50.1" },
    "ZScalerWashingtonDC-136.226.52.0-23" : { "cidr" = "136.226.52.0/23",
      "end"                                          = "136.226.53.254",
    "start" = "136.226.52.1" },
    "ZScalerAmsterdamII-147.161.172.0-23" : { "cidr" = "147.161.172.0/23",
      "end"                                          = "147.161.173.254",
    "start" = "147.161.172.1" },
    "ZScalerAmsterdamII-185.46.212.0-23" : { "cidr" = "185.46.212.0/23",
      "end"                                         = "185.46.213.254",
    "start" = "185.46.212.1" },
    "ZScalerAmsterdamII-165.225.240.0-23" : { "cidr" = "165.225.240.0/23",
      "end"                                          = "165.225.241.254",
    "start" = "165.225.240.1" },
    "ZScalerBrusselsII-165.225.12.0-23" : { "cidr" = "165.225.12.0/23",
      "end"                                        = "165.225.13.254",
    "start" = "165.225.12.1" },
    "ZScalerCapetown-196.23.154.96-27" : { "cidr" = "196.23.154.96/27",
      "end"                                       = "196.23.154.126",
    "start" = "196.23.154.97" },
    "ZScalerCopenhagenII-165.225.194.0-23" : { "cidr" = "165.225.194.0/23",
      "end"                                           = "165.225.195.254",
    "start" = "165.225.194.1" },
    "ZScalerDubaiI-147.161.160.0-23" : { "cidr" = "147.161.160.0/23",
      "end"                                     = "147.161.161.254",
    "start" = "147.161.160.1" },
    "ZScalerFrankfurtIV-147.161.164.0-23" : { "cidr" = "147.161.164.0/23",
      "end"                                          = "147.161.165.254",
    "start" = "147.161.164.1" },
    "ZScalerFrankfurtIV-165.225.72.0-22" : { "cidr" = "165.225.72.0/22",
      "end"                                         = "165.225.75.254",
    "start" = "165.225.72.1" },
    "ZScalerFrankfurtIV-165.225.26.0-23" : { "cidr" = "165.225.26.0/23",
      "end"                                         = "165.225.27.254",
    "start" = "165.225.26.1" },
    "ZScalerFrankfurtIV-147.161.164.0-23" : { "cidr" = "147.161.164.0/23",
      "end"                                          = "147.161.165.254",
    "start" = "147.161.164.1" },
    "ZScalerHelsinkiI-147.161.186.0-23" : { "cidr" = "147.161.186.0/23",
      "end"                                        = "147.161.187.254",
    "start" = "147.161.186.1" },
    "ZScalerJohannesburgII-197.98.201.0-24" : { "cidr" = "197.98.201.0/24",
      "end"                                            = "197.98.201.254",
    "start" = "197.98.201.1" },
    "ZScalerJohannesburgIII-147.161.162.0-23" : { "cidr" = "147.161.162.0/23",
      "end"                                              = "147.161.163.254",
    "start" = "147.161.162.1" },
    "ZScalerLagosII-154.113.23.0-24" : { "cidr" = "154.113.23.0/24",
      "end"                                     = "154.113.23.254",
    "start" = "154.113.23.1" },
    "ZScalerLondonIII-165.225.80.0-22" : { "cidr" = "165.225.80.0/22",
      "end"                                       = "165.225.83.254",
    "start" = "165.225.80.1" },
    "ZScalerLondonIII-165.225.16.0-23" : { "cidr" = "165.225.16.0/23",
      "end"                                       = "165.225.17.254",
    "start" = "165.225.16.1" },
    "ZScalerLondonIII-147.161.166.0-23" : { "cidr" = "147.161.166.0/23",
      "end"                                        = "147.161.167.254",
    "start" = "147.161.166.1" },
    "ZScalerMadridIII-165.225.92.0-23" : { "cidr" = "165.225.92.0/23",
      "end"                                       = "165.225.93.254",
    "start" = "165.225.92.1" },
    "ZScalerMadridIII-147.161.190.0-23" : { "cidr" = "147.161.190.0/23",
      "end"                                        = "147.161.191.254",
    "start" = "147.161.190.1" },
    "ZScalerManchesterI-165.225.196.0-23" : { "cidr" = "165.225.196.0/23",
      "end"                                          = "165.225.197.254",
    "start" = "165.225.196.1" },
    "ZScalerManchesterI-165.225.198.0-23" : { "cidr" = "165.225.198.0/23",
      "end"                                          = "165.225.199.254",
    "start" = "165.225.198.1" },
    "ZScalerManchesterI-147.161.236.0-23" : { "cidr" = "147.161.236.0/23",
      "end"                                          = "147.161.237.254",
    "start" = "147.161.236.1" },
    "ZScalerMarseilleI-147.161.178.0-23" : { "cidr" = "147.161.178.0/23",
      "end"                                         = "147.161.179.254",
    "start" = "147.161.178.1" },
    "ZScalerMarseilleI-147.161.180.0-23" : { "cidr" = "147.161.180.0/23",
      "end"                                         = "147.161.181.254",
    "start" = "147.161.180.1" },
    "ZScalerMarseilleI-147.161.182.0-23" : { "cidr" = "147.161.182.0/23",
      "end"                                         = "147.161.183.254",
    "start" = "147.161.182.1" },
    "ZScalerMilanIII-147.161.244.0-23" : { "cidr" = "147.161.244.0/23",
      "end"                                       = "147.161.245.254",
    "start" = "147.161.244.1" },
    "ZScalerMilanIII-165.225.202.0-23" : { "cidr" = "165.225.202.0/23",
      "end"                                       = "165.225.203.254",
    "start" = "165.225.202.1" },
    "ZScalerMoscowIII-165.225.90.0-23" : { "cidr" = "165.225.90.0/23",
      "end"                                       = "165.225.91.254",
    "start" = "165.225.90.1" },
    "ZScalerMunichI-147.161.176.0-23" : { "cidr" = "147.161.176.0/23",
      "end"                                      = "147.161.177.254",
    "start" = "147.161.176.1" },
    "ZScalerMunichI-147.161.250.0-23" : { "cidr" = "147.161.250.0/23",
      "end"                                      = "147.161.251.254",
    "start" = "147.161.250.1" },
    "ZScalerMunichI-147.161.168.0-23" : { "cidr" = "147.161.168.0/23",
      "end"                                      = "147.161.169.254",
    "start" = "147.161.168.1" },
    "ZScalerMunichI-147.161.170.0-23" : { "cidr" = "147.161.170.0/23",
      "end"                                      = "147.161.171.254",
    "start" = "147.161.170.1" },
    "ZScalerOsloII-213.52.102.0-24" : { "cidr" = "213.52.102.0/24",
      "end"                                    = "213.52.102.254",
    "start" = "213.52.102.1" },
    "ZScalerParisII-165.225.76.0-23" : { "cidr" = "165.225.76.0/23",
      "end"                                     = "165.225.77.254",
    "start" = "165.225.76.1" },
    "ZScalerParisII-147.161.184.0-23" : { "cidr" = "147.161.184.0/23",
      "end"                                      = "147.161.185.254",
    "start" = "147.161.184.1" },
    "ZScalerParisII-147.161.184.0-23" : { "cidr" = "147.161.184.0/23",
      "end"                                      = "147.161.185.254",
    "start" = "147.161.184.1" },
    "ZScalerParisII-165.225.20.0-23" : { "cidr" = "165.225.20.0/23",
      "end"                                     = "165.225.21.254",
    "start" = "165.225.20.1" },
    "ZScalerRouenI-165.225.204.0-23" : { "cidr" = "165.225.204.0/23",
      "end"                                     = "165.225.205.254",
    "start" = "165.225.204.1" },
    "ZScalerStockholmIII-165.225.192.0-23" : { "cidr" = "165.225.192.0/23",
      "end"                                           = "165.225.193.254",
    "start" = "165.225.192.1" },
    "ZScalerStockholmIII-147.161.188.0-23" : { "cidr" = "147.161.188.0/23",
      "end"                                           = "147.161.189.254",
    "start" = "147.161.188.1" },
    "ZScalerTelAviv-94.188.131.0-25" : { "cidr" = "94.188.131.0/25",
      "end"                                     = "94.188.131.126",
    "start" = "94.188.131.1" },
    "ZScalerViennaI-165.225.200.0-23" : { "cidr" = "165.225.200.0/23",
      "end"                                      = "165.225.201.254",
    "start" = "165.225.200.1" },
    "ZScalerWarsawII-147.161.248.0-23" : { "cidr" = "147.161.248.0/23",
      "end"                                       = "147.161.249.254",
    "start" = "147.161.248.1" },
    "ZScalerWarsawII-165.225.206.0-23" : { "cidr" = "165.225.206.0/23",
      "end"                                       = "165.225.207.254",
    "start" = "165.225.206.1" },
    "ZScalerZurich-147.161.246.0-23" : { "cidr" = "147.161.246.0/23",
      "end"                                     = "147.161.247.254",
    "start" = "147.161.246.1" },
    "ZScalerZurich-165.225.94.0-23" : { "cidr" = "165.225.94.0/23",
      "end"                                    = "165.225.95.254",
    "start" = "165.225.94.1" },

    "ZScalerFDC1-185.46.212.0-22" : { "cidr" = "185.46.212.0/22",
      "end"                                  = "185.46.215.254",
    "start" = "185.46.212.1" },
    "ZScalerFDC2-104.129.192.0-20" : { "cidr" = "104.129.192.0/20",
      "end"                                   = "104.129.207.254",
    "start" = "104.129.192.1" },
    "ZScalerFDC3-165.225.0.0-17" : { "cidr" = "165.225.0.0/17",
      "end"                                 = "165.225.127.254",
    "start" = "165.225.0.1" },
    "ZScalerFDC4-165.225.192.0-18" : { "cidr" = "165.225.192.0/18",
      "end"                                   = "165.225.255.254",
    "start" = "165.225.192.1" },
    "ZScalerFDC5-147.161.128.0-17" : { "cidr" = "147.161.128.0/17",
      "end"                                   = "147.161.255.254",
    "start" = "147.161.128.1" },
    "ZScalerFDC6-136.226.0.0-16" : { "cidr" = "136.226.0.0/16",
      "end"                                 = "136.226.255.254",
    "start" = "136.226.0.1" },
    "ZScalerFDC7-137.83.128.0-18" : { "cidr" = "137.83.128.0/18",
      "end"                                  = "137.83.191.254",
    "start" = "137.83.128.1" },
  }
 
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
