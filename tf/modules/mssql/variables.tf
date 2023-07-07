variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {

}

variable "db_server_name" {
  description = "Database server name"
}

variable "db_name" {
  description = "Database name"
}

variable "sku_name" {
  description = "SKU name for Database."
}

variable "sql_collation" {
  description = "Collation for database"
}

variable "db_size" {
  description = "Database max size"
}

variable "job_agent_name" {
  description = "Job agent name"
}

variable "key_vault_id" {
  description = "Key vault id"
}

variable "workspace_name" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "ad_display_name" {

}

variable "zscaler_whitelist" {

}

variable "sql_log_storage_account_name" {

}

variable "sql_vul_asses_storage_account_name" {

}
variable "frontend_whitelist" {

}

# variable "virtual_network_subnet_ids" {

# }

variable "virtual_network_rules" {

}

variable "storage_account_network_rules" {
  description = "Network rules restricing access to the storage account."
  type        = object({ default_action = string, bypass = list(string), ip_rules = list(string), subnet_ids = list(string) })
  default     = null
}

variable "storage_account_lifecycles" {

}

variable "metric_alert_monitor_action_group_id" {

}