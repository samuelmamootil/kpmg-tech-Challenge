variable "name" {

}

variable "resource_group_name" {

}

variable "location" {

}

variable "app_service_ids" {

}

variable "current_stack" {
  type = string
}

variable "java_version" {
  type = string
}

variable "java_container" {
  type = string
}

variable "java_container_version" {
  type = string
}

variable "mssql_connections_string" {
  type      = string
  sensitive = true
}

variable "application_insights_instrumentation_key" {
  sensitive = true
}

variable "application_insights_connection_string" {
  sensitive = true
}

variable "vnet_integration_subnet_id" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "private_dns_zone_vnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "ip_restrictions" {

}

variable "java_opts" {

}

variable "scm_ip_restrictions" {
  
}