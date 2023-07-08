output "id" {
  #value       = [for wa in azurerm_windows_web_app.wa : wa.id]
  value = {
    for wa in azurerm_windows_web_app.wa :
    wa.name => { id = wa.id }
  }
}

output "outbound_ip_address_list" {
  value = [for wa in azurerm_windows_web_app.wa : wa.outbound_ip_address_list]
}

output "outbound_ip_addresses" {
  value = [for wa in azurerm_windows_web_app.wa : wa.outbound_ip_addresses]
}

output "possible_outbound_ip_address_list" {
  value = [for wa in azurerm_windows_web_app.wa : wa.possible_outbound_ip_address_list]
}

output "possible_outbound_ip_addresses" {
  value = [for wa in azurerm_windows_web_app.wa : wa.possible_outbound_ip_addresses]
}