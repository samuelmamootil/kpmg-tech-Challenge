variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "name" {
  type = list(string)
}

variable "service_plan_id" {
  type = string
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

variable "workspace_id" {
  type = string
}

variable "private_dns_zone_vnet_id" {
  type = string
}

variable "vnet_integration_subnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
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

variable "ip_restrictions" {

}

variable "scm_use_main_ip_restriction" {
  default = false
}

variable "scm_ip_restrictions" {

}

variable "java_opts" {

}

variable "metric_alert_monitor_action_group_id" {

}