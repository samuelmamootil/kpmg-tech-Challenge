variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "workspace_name" {
  description = "Name of a Log Analytics workspace."
  type        = string
}

variable "sku" {
  description = "Sku of Log Analytics Workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "The workspace data retention in days."
  type        = number
  default     = 30
}

variable "workspace_id" {
  description = "Id of Log Analytics Workspace, used for shipping diagnostic logs."
  type        = string
}
