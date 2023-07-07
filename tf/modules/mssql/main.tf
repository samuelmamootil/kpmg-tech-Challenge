# locals {
#   frontend_whitelist = {
#       for ip in distinct(flatten(var.frontend_whitelist)):
#          format("%s-%s", "frontend", ip) => {ip_address = ip}
#   }
# }

#---------------------------------------------------------
#   Getting ResourcGroup Information
#----------------------------------------------------------

data "azurerm_resource_group" "azure_rg" {
  name = var.resource_group_name
}

resource "random_string" "sql_server_admin_user" {
  length  = 20
  special = false
}

resource "azurerm_key_vault_secret" "sql_server_admin_user" {
  name         = "${var.db_server_name}-admin-user"
  value        = random_string.sql_server_admin_user.result
  content_type = "login"
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "random_password" "sql_server_admin_password" {
  length      = 20
  lower       = true
  min_lower   = 2
  upper       = true
  min_upper   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
}

resource "azurerm_key_vault_secret" "sql_server_admin_password" {
  name         = "${var.db_server_name}-admin-password"
  value        = random_password.sql_server_admin_password.result
  content_type = "password"
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [tags]
  }
}

module "sql_auditing_storage_account" {
  source                     = "../../modules/storageaccount"
  storage_account_name       = var.sql_log_storage_account_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  skuname                    = "Standard_LRS"
  workspace_id               = var.workspace_id
  vnet_id                    = var.vnet_id
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  # virtual_network_subnet_ids = var.virtual_network_subnet_ids
  network_rules = var.storage_account_network_rules
  lifecycles = [
    {
      rule_name                  = "DeleteAfter90Days"
      prefix_match               = [""]
      tier_to_cool_after_days    = -1
      tier_to_archive_after_days = -1
      delete_after_days          = 90
      snapshot_delete_after_days = 90
    }
  ]
}

module "sql_vulnerability_storage_account" {
  source                     = "../../modules/storageaccount"
  storage_account_name       = var.sql_vul_asses_storage_account_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  skuname                    = "Standard_LRS"
  containers_list            = [] #[{ name = "sql-vulnerability-assessment", access_type = "private" }]
  workspace_id               = var.workspace_id
  vnet_id                    = var.vnet_id
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  # virtual_network_subnet_ids = var.virtual_network_subnet_ids
  network_rules = var.storage_account_network_rules
  lifecycles = [
    {
      rule_name = contains(split("-", var.resource_group_name), "prod") ? "DeleteAfter90Days" : "DeleteAfter30Days"

      blob_types = [
        "appendBlob",
        "blockBlob"
      ]
      prefix_match = [
        "$logs/",
        "vulnerability-assessment/scans/${var.db_server_name}/DBAUtility/scan_",
        "vulnerability-assessment/scans/${var.db_server_name}/master/scan_",
        "vulnerability-assessment/scans/${var.db_server_name}/${var.db_name}/scan_",
      ]

      delete_after_days = contains(split("-", var.resource_group_name), "prod") ? 90 : 30
    }
  ]
}

# resource "azurerm_role_assignment" "data_contributor_role" {
#   scope                = module.sql_auditing_storage_account.storage_account_id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_mssql_server.sql_server.identity[0].principal_id
#   depends_on = [
#     azurerm_mssql_server.sql_server,
#     module.sql_auditing_storage_account
#   ]
# }

# data "azurerm_subscription" "primary" {
# }

# resource "azurerm_mssql_server_extended_auditing_policy" "extended_auditing_policy" {
#   server_id        = azurerm_mssql_server.sql_server.id
#   storage_endpoint = module.sql_auditing_storage_account.primary_blob_endpoint
#   # storage_account_access_key              = module.sql_auditing_storage_account.primary_access_key
#   # storage_account_access_key_is_secondary = false
#   retention_in_days = 7
#   log_monitoring_enabled = false

#   storage_account_subscription_id = data.azurerm_subscription.primary.subscription_id

#   depends_on = [
#     azurerm_mssql_server.sql_server
#   ]
# }

# resource "azurerm_mssql_server_security_alert_policy" "security_alert_policy" {
#   resource_group_name  = var.resource_group_name
#   server_name          = azurerm_mssql_server.sql_server.name
#   state                = "Enabled"
#   # retention_days       = 6
#   email_account_admins = true
#   # email_addresses      = var.azure_sql_security_policy_emails
# }

# resource "azurerm_mssql_server_vulnerability_assessment" "vulnerability_assessment" {
#   server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.security_alert_policy.id
#   storage_container_path          = "${module.sql_vulnerability_storage_account.primary_blob_endpoint}sql-vulnerability-assessment/"
#   #storage_account_access_key      = module.sql_vulnerability_storage_account.primary_access_key

#   recurring_scans {
#     enabled                   = true
#     email_subscription_admins = true
#     #emails                    = var.azure_sql_vulnerability_assessment_emails
#   }

#   depends_on = [
#     azurerm_mssql_server.sql_server,
#     azurerm_mssql_server_security_alert_policy.security_alert_policy,
#     module.sql_vulnerability_storage_account
#   ]
# }

# data "azuread_group" "sql_server_admin_ad_group" {
#   display_name = var.ad_display_name
# }

data "azurerm_client_config" "current" {}

#---------------------------------------------------------
#   Database server creation
#---------------------------------------------------------
resource "azurerm_mssql_server" "sql_server" {
  name                          = var.db_server_name
  resource_group_name           = data.azurerm_resource_group.azure_rg.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = azurerm_key_vault_secret.sql_server_admin_user.value
  administrator_login_password  = azurerm_key_vault_secret.sql_server_admin_password.value
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  # azuread_administrator {
  #   azuread_authentication_only = false
  #   login_username              = var.ad_display_name
  #   object_id                   = data.azuread_group.sql_server_admin_ad_group.object_id
  #   tenant_id                   = data.azurerm_client_config.current.tenant_id
  # }

  azuread_administrator {
    azuread_authentication_only = false
    login_username              = "MWS Administrativ personnel"
    object_id                   = "19c5208f-3186-4759-8449-628f5de67247"
    tenant_id                   = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    #data.azuread_group.sql_server_admin_ad_group,
    data.azurerm_client_config.current
  ]
}


resource "azurerm_management_lock" "cannot_delete_sql_server" {
  name       = "${var.db_server_name}-cannot-delete"
  scope      = azurerm_mssql_server.sql_server.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted!"
}

#---------------------------------------------------------
#   Database creation
#---------------------------------------------------------

resource "azurerm_mssql_database" "sql_db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = var.sql_collation
  max_size_gb    = var.db_size
  read_scale     = false
  sku_name       = var.sku_name
  zone_redundant = false

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_management_lock" "cannot_delete_sql_db" {
  name       = "${var.db_name}-cannot-delete"
  scope      = azurerm_mssql_database.sql_db.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted!"
}


resource "azurerm_mssql_database" "DBAUtility" {
  name                 = "DBAUtility"
  server_id            = azurerm_mssql_server.sql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = 2
  read_scale           = false
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_management_lock" "cannot_delete_DBAUtility" {
  name       = "DBAUtility-cannot-delete"
  scope      = azurerm_mssql_database.DBAUtility.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted!"
}

module "DBAUtility_diagnostics_settings" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_mssql_database.DBAUtility.id
  workspace_id       = var.workspace_id
  depends_on         = [azurerm_mssql_database.DBAUtility]
}

#---------------------------------------------------------
#   Job agent 
#---------------------------------------------------------
# resource "azurerm_mssql_job_agent" "job_agent" {
#   name        = var.job_agent_name
#   location    = data.azurerm_resource_group.azure_rg.location
#   database_id = azurerm_mssql_database.sql_db.id
# }

resource "azurerm_mssql_virtual_network_rule" "vnet_rules" {
  for_each  = var.virtual_network_rules
  name      = each.key
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = each.value.subnet_id

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

resource "azurerm_mssql_firewall_rule" "zscaler_whitelist" {
  for_each         = var.zscaler_whitelist
  name             = each.key
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start
  end_ip_address   = each.value.end

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

# resource "azurerm_mssql_firewall_rule" "frontend_whitelist" {
#   for_each = local.frontend_whitelist
#   name = each.key
#   server_id = azurerm_mssql_server.sql_server.id
#   start_ip_address = each.value.ip_address
#   end_ip_address = each.value.ip_address
# }

module "sql_db_diagnostics_settings" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_mssql_database.sql_db.id
  workspace_id       = var.workspace_id
  depends_on         = [azurerm_mssql_database.sql_db]
}

# module "private_dns_zone" {
#   source                          = "../private_dns_zone"
#   resource_group_name             = var.resource_group_name
#   private_dns_zone_name           = "privatelink.database.windows.net"
#   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_sql"
#   vnet_id                         = var.vnet_id
# }

# module "private_endpoint" {
#   source                          = "../private_endpoint"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   name                            = "${azurerm_mssql_server.sql_server.name}-priv-endpoint"
#   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
#   private_service_connection_name = "${azurerm_mssql_server.sql_server.name}-priv-serv-con"
#   endpoint_resource_id            = azurerm_mssql_server.sql_server.id
#   private_dns_zone_name           = module.private_dns_zone.private_dns_zone_name
#   subresource_names               = ["sqlServer"]

#   # depends_on = [
#   #   module.private_dns_zone,
#   #   azurerm_mssql_server.sql_server
#   # ]
# }

# data "azurerm_private_endpoint_connection" "pe_conn" {
#   name                = "${azurerm_mssql_server.sql_server.name}-priv-endpoint"
#   resource_group_name = var.resource_group_name
#   depends_on          = [module.private_endpoint]
# }

# resource "azurerm_private_dns_a_record" "a_record" {
#   name                = azurerm_mssql_server.sql_server.name
#   zone_name           = "privatelink.database.windows.net"
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [data.azurerm_private_endpoint_connection.pe_conn.private_service_connection.0.private_ip_address]


#   lifecycle {
#     ignore_changes = [tags]
#   }

#   #   depends_on = [
#   #     data.azurerm_private_endpoint_connection.pe_conn
#   #   ]
# }

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  solution_name         = "AzureSQLAnalytics"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = var.workspace_id
  workspace_name        = var.workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureSQLAnalytics"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

module "sql_db_metric_alerts" {
  source = "../../modules/mssql_metric_alerts"

  resource_name                        = azurerm_mssql_database.sql_db.name
  resource_id                          = azurerm_mssql_database.sql_db.id
  metric_alert_monitor_action_group_id = var.metric_alert_monitor_action_group_id
  resource_group_name                  = var.resource_group_name
}

module "DBAUtility_metric_alerts" {
  source = "../../modules/mssql_metric_alerts"

  resource_name                        = azurerm_mssql_database.DBAUtility.name
  resource_id                          = azurerm_mssql_database.DBAUtility.id
  metric_alert_monitor_action_group_id = var.metric_alert_monitor_action_group_id
  resource_group_name                  = var.resource_group_name
}