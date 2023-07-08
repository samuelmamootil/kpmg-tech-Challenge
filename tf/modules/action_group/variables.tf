variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the alert group in to."
}
variable "name" {
  description = "The name of Action Group instance"
  type        = string
}

variable "settings" {
  description = "Configuration object for the monitor action group"
}