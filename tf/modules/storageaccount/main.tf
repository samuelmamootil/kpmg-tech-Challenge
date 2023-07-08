data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

#-------------------------------
# Local Declarations
#-------------------------------
locals {
  account_tier             = (var.account_kind == "FileStorage" ? "Premium" : split("_", var.skuname)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.skuname)[1])
}
#---------------------------------------------------------
# Storage Account Creation  
#----------------------------------------------------------
resource "azurerm_storage_account" "storeacc" {
  name                            = lower(var.storage_account_name)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = var.account_kind
  account_tier                    = local.account_tier
  account_replication_type        = local.account_replication_type
  enable_https_traffic_only       = var.enable_https_traffic
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
    versioning_enabled       = var.enable_versioning
    last_access_time_enabled = var.last_access_time_enabled
    change_feed_enabled      = var.change_feed_enabled
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action             = "Deny"
      bypass                     = var.network_rules.bypass
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.subnet_ids
    }
  }
}

#--------------------------------------
# Storage Advanced Threat Protection 
#--------------------------------------
resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = azurerm_storage_account.storeacc.id
  enabled            = var.enable_advanced_threat_protection
}

#-------------------------------
# Storage Container Creation
#-------------------------------
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.storeacc.name
  container_access_type = var.containers_list[count.index].access_type
}

#-------------------------------
# Storage Fileshare Creation
#-------------------------------
resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.storeacc.name
  quota                = var.file_shares[count.index].quota
}

#-------------------------------
# Storage Tables Creation
#-------------------------------
resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name
}

#-------------------------------
# Storage Queue Creation
#-------------------------------
resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name
}

#-------------------------------
# Storage Lifecycle Management
#-------------------------------
resource "azurerm_storage_management_policy" "lcpolicy" {
  count              = length(var.lifecycles) == 0 ? 0 : 1
  storage_account_id = azurerm_storage_account.storeacc.id

  dynamic "rule" {
    for_each = var.lifecycles
    iterator = rule
    content {
      name    = rule.value.rule_name
      enabled = true
      filters {
        blob_types   = [
          "appendBlob",
          "blockBlob"
        ]
        prefix_match = rule.value.prefix_match
      }
      actions {
        base_blob {
          # tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          # tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than = rule.value.delete_after_days
        }
        snapshot {
          delete_after_days_since_creation_greater_than = rule.value.delete_after_days
        }
        version {
          delete_after_days_since_creation = rule.value.delete_after_days
        }

      }
    }
  }
}

# resource "azurerm_storage_account_network_rules" "sa_network_rules" {
#   storage_account_id = azurerm_storage_account.storeacc.id
#   default_action     = "Deny"
#   bypass             = ["AzureServices"]
#   virtual_network_subnet_ids = var.virtual_network_subnet_ids
# }

module "storage_account_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_storage_account.storeacc.id
  workspace_id       = var.workspace_id
}

module "storage_account_blob_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = "${azurerm_storage_account.storeacc.id}/blobServices/default"
  workspace_id       = var.workspace_id
}

module "storage_account_queue_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = "${azurerm_storage_account.storeacc.id}/queueServices/default"
  workspace_id       = var.workspace_id
}

module "storage_account_table_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = "${azurerm_storage_account.storeacc.id}/tableServices/default"
  workspace_id       = var.workspace_id
}

module "storage_account_file_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = "${azurerm_storage_account.storeacc.id}/fileServices/default"
  workspace_id       = var.workspace_id
}
# module "private_dns_zone_sa_blob" {
#   source                          = "../private_dns_zone"
#   resource_group_name             = var.resource_group_name
#   private_dns_zone_name           = "privatelink.blob.core.windows.net"
#   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_sa_blob"
#   vnet_id                         = var.vnet_id
# }

# module "private_dns_zone_sa_table" {
#   source                          = "../private_dns_zone"
#   resource_group_name             = var.resource_group_name
#   private_dns_zone_name           = "privatelink.table.core.windows.net"
#   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_sa_table"
#   vnet_id                         = var.vnet_id
# }

# module "private_endpoint_blob" {
#   source                          = "../private_endpoint"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   name                            = "${azurerm_storage_account.storeacc.name}-blob-priv-endpoint"
#   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
#   private_service_connection_name = "${azurerm_storage_account.storeacc.name}-blob-priv-serv-con"
#   endpoint_resource_id            = azurerm_storage_account.storeacc.id
#   private_dns_zone_name           = module.private_dns_zone_sa_blob.private_dns_zone_name
#   subresource_names               = ["blob"]
#   depends_on = [
#     module.private_dns_zone_sa_blob
#   ]
# }

# module "private_endpoint_table" {
#   source                          = "../private_endpoint"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   name                            = "${azurerm_storage_account.storeacc.name}-table-priv-endpoint"
#   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
#   private_service_connection_name = "${azurerm_storage_account.storeacc.name}-table-priv-serv-con"
#   endpoint_resource_id            = azurerm_storage_account.storeacc.id
#   private_dns_zone_name           = module.private_dns_zone_sa_table.private_dns_zone_name
#   subresource_names               = ["table"]
#   depends_on = [
#     module.private_dns_zone_sa_table
#   ]
# }