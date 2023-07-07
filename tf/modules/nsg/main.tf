#---------------------------------------------------------
#   Getting ResourcGroup Information for subnet deployment
#----------------------------------------------------------
data "azurerm_resource_group" "resource_group" {

  name = var.resource_group_name
}

#---------------------------------------------------------
#                 NSG Creation  
#----------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  #tags                = var.tags

  timeouts {
    create = "5m"
    delete = "10m"
  }

  security_rule = var.nsgrules

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}


#---------------------------------------------------------
#      Security Rules that needs to be added to NSG   
#----------------------------------------------------------

# resource "azurerm_network_security_rule" "nsgrule" {
#   for_each = var.nsgrules

#   resource_group_name         = data.azurerm_resource_group.resource_group.name
#   network_security_group_name = azurerm_network_security_group.nsg.name
#   access                      = each.value.access
#   description                 = each.value.description
#   destination_address_prefix  = each.value.destination_address_prefix
#   # destination_address_prefixes               = each.value.destination_address_prefixes
#   # destination_application_security_group_ids = each.value.destination_application_security_group_ids
#   # destination_port_range = each.value.destination_port_range
#   destination_port_ranges                    = each.value.destination_port_ranges
#   direction             = each.value.direction
#   name                  = each.value.name
#   priority              = each.value.priority
#   protocol              = each.value.protocol
#   source_address_prefix = each.value.source_address_prefix
#   # source_address_prefixes                    = each.value.source_address_prefixes
#   # source_application_security_group_ids      = each.value.source_application_security_group_ids
#   source_port_range = each.value.source_port_range
#   # source_port_ranges                         = each.value.source_port_ranges


#   # name                        = each.key
#   # direction                   = each.value.direction
#   # access                      = each.value.access
#   # priority                    = each.value.priority
#   # protocol                    = each.value.protocol
#   # source_port_range           = each.value.source_port_range
#   # destination_port_range      = each.value.destination_port_range
#   # source_address_prefix       = each.value.source_address_prefix
#   # destination_address_prefix  = each.value.destination_address_prefix
#   # resource_group_name         = data.azurerm_resource_group.resource_group.name
#   # network_security_group_name = azurerm_network_security_group.nsg.name

#   depends_on = [
#     azurerm_network_security_group.nsg
#   ]
# }

module "network_security_group_diagnostics" {
  source             = "../diagnostics_settings"
  target_resource_id = azurerm_network_security_group.nsg.id
  workspace_id       = var.workspace_id

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}