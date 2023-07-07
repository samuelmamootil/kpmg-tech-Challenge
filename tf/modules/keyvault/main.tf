
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
#---------------------------------------------------------
#                   Local Declarations
#---------------------------------------------------------
locals {
  service_principal_object_id = data.azurerm_client_config.current.object_id
  self_permissions = {
    object_id               = local.service_principal_object_id
    tenant_id               = data.azurerm_client_config.current.tenant_id
    key_permissions         = ["Create", "Delete", "Get", "Backup", "Decrypt", "Encrypt", "Import", "List", "Purge", "Recover", "Restore", "Sign", "Update", "Verify"]
    secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
    certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
    storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
  }
}
#---------------------------------------------------------
#                     Keyvault Creation 
#---------------------------------------------------------- 
resource "azurerm_key_vault" "kv" {
  name                            = lower(var.key_vault_name)
  resource_group_name             = data.azurerm_resource_group.resource_group.name
  location                        = var.location
  tenant_id                       = data.azurerm_subscription.current.tenant_id
  sku_name                        = var.sku_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  purge_protection_enabled        = var.enable_purge_protection
  lifecycle {
    ignore_changes = [
      tags,
      access_policy
    ]
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }
  #---------------------------------------------------------
  #       Providing  Service Principal Access to keyvault
  #---------------------------------------------------------- 
  dynamic "access_policy" {
    for_each = local.service_principal_object_id != "" ? [local.self_permissions] : []
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
}

resource "azurerm_management_lock" "cannot_delete_keyvault" {
  name       = "${lower(var.key_vault_name)}-cannot-delete"
  scope      = azurerm_key_vault.kv.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted!"
}

resource "random_password" "passwd" {
  for_each    = var.secrets
  length      = 24
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  min_special = 4

  keepers = {
    name = each.key
  }
}
#---------------------------------------------------------
#               Adding Keyvault secrets
#---------------------------------------------------------- 
resource "azurerm_key_vault_secret" "keys" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = azurerm_key_vault.kv.id
}


module "key_vault_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_key_vault.kv.id
  workspace_id       = var.workspace_id
}

resource "azurerm_log_analytics_solution" "key_vault_analytics" {
  solution_name         = "KeyVaultAnalytics"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  workspace_resource_id = var.workspace_id
  workspace_name        = element(split("/", var.workspace_id), length(split("/", var.workspace_id)) - 1)

  lifecycle {
    ignore_changes = [tags]
  }

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/KeyVaultAnalytics"
  }
}

# module "private_dns_zone" {
#   source                          = "../private_dns_zone"
#   resource_group_name             = var.resource_group_name
#   private_dns_zone_name           = "privatelink.vaultcore.azure.net"
#   private_dns_zone_vnet_link_name = "private_dns_zone_vnet_link_kv"
#   vnet_id                         = var.vnet_id
# }

# module "private_endpoint" {
#   source                          = "../private_endpoint"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   name                            = "${azurerm_key_vault.kv.name}-priv-endpoint"
#   private_endpoint_subnet_id      = var.private_endpoint_subnet_id
#   private_service_connection_name = "${azurerm_key_vault.kv.name}-priv-serv-con"
#   endpoint_resource_id            = azurerm_key_vault.kv.id
#   private_dns_zone_name           = module.private_dns_zone.private_dns_zone_name
#   subresource_names               = ["vault"]
#   # depends_on = [
#   #   module.private_dns_zone
#   # ]
# }

# data "azurerm_private_endpoint_connection" "pe_conn" {
#   name                = "${azurerm_key_vault.kv.name}-priv-endpoint"
#   resource_group_name = var.resource_group_name
#   depends_on          = [module.private_endpoint]
# }

# resource "azurerm_private_dns_a_record" "a_record" {
#   name                = azurerm_key_vault.kv.name
#   zone_name           = "privatelink.vaultcore.azure.net"
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