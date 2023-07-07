data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

#---------------------------------------------------------
#             Virtual Network Creation  
#----------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  #tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
