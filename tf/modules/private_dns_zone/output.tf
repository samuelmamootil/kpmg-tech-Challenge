output "private_dns_zone_name" {
  value = element(split("/", azurerm_private_dns_zone.private_dns_zone.id), length(split("/", azurerm_private_dns_zone.private_dns_zone.id)) - 1)
}
