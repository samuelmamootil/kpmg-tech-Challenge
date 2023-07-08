
#---------------------------------------------------------
#   Getting ResourcGroup Information for subnet deployment
#----------------------------------------------------------

data "azurerm_resource_group" "azure_rg" {
  name = var.resource_group_name
}

#---------------------------------------------------------
#   Getting Vnet Information for subnet deployment
#----------------------------------------------------------

data "azurerm_virtual_network" "azure_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.azure_rg.name
}


data "azurerm_network_security_group" "azure_nsg" {
  name                = var.nsg_name
  resource_group_name = data.azurerm_resource_group.azure_rg.name
}

#---------------------------------------------------------
#                 Subnet  Creation  
#----------------------------------------------------------

resource "azurerm_subnet" "az_subnet" {
  name                                           = var.subnet_name
  resource_group_name                            = data.azurerm_resource_group.azure_rg.name
  virtual_network_name                           = data.azurerm_virtual_network.azure_vnet.name
  address_prefixes                               = var.subnet_prefix
  service_endpoints                              = var.service_endpoints
  service_endpoint_policy_ids                    = var.service_endpoint_policy_ids
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
  enforce_private_link_service_network_policies  = var.enforce_private_link_service_network_policies
}

#---------------------------------------------------------
#                 Subnet-NSG Association  
#----------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.az_subnet.id
  network_security_group_id = data.azurerm_network_security_group.azure_nsg.id

  timeouts {
    create = "5m"
    delete = "10m"
  }
}