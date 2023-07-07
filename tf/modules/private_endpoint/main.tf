##################################################################################
#             Creates a New Private Endpoint for a specified Resource
##################################################################################

##################################################################################
#                               Data Lookups
##################################################################################


data "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

data "azurerm_private_endpoint_connection" "private_link_connection" {
  name                = azurerm_private_endpoint.pe.name
  resource_group_name = azurerm_private_endpoint.pe.resource_group_name
}

##################################################################################
#                      Create a new Private Endpoint
##################################################################################
resource "azurerm_private_endpoint" "pe" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    is_manual_connection           = false
    private_connection_resource_id = var.endpoint_resource_id
    subresource_names              = var.subresource_names
  }

  # private_dns_zone_group {
  #   name                 = "default"
  #   private_dns_zone_ids = [data.azurerm_private_dns_zone.private_dns_zone.id]
  # }


  lifecycle {
    ignore_changes = [tags]
  }
}