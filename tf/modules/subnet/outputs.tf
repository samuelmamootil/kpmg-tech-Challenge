
output "az_subnet_id" {
  description = "The id of the newly created subnet"
  value       = azurerm_subnet.az_subnet.id
}

output "az_subnet_name" {
  description = "The Name of the newly created subnet"
  value       = azurerm_subnet.az_subnet.name
}

output "az_subnet_address_prefix" {
  description = "The address space of the newly created subnet"
  value       = azurerm_subnet.az_subnet.address_prefixes
}

output "az_subnet_vnet" {
  description = "The virtual network of the newly created subnet"
  value       = azurerm_subnet.az_subnet.virtual_network_name
}