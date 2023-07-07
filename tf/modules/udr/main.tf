##################################################################################
#             Creates a New Private Endpoint for a specified Resource
##################################################################################

##################################################################################
#                               Data Lookups
##################################################################################
data "azurerm_resource_group" "azure_rg" {
  name = var.resource_group_name
}


##################################################################################
#                      Create a new Route Table
##################################################################################

resource "azurerm_route_table" "rtable" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.azure_rg.name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
##################################################################################
#                       Define Route
##################################################################################

resource "azurerm_route" "route" {
  name                   = var.route_names[count.index]
  resource_group_name    = data.azurerm_resource_group.azure_rg.name
  route_table_name       = azurerm_route_table.rtable.name
  address_prefix         = var.route_prefixes[count.index]
  next_hop_type          = var.route_nexthop_types[count.index]
  next_hop_in_ip_address = var.next_hop_in_ip_address[count.index]
  count                  = length(var.route_names)
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.rtable.id
}