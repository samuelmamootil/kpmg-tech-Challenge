variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "application_type" {
  type    = string
  default = "web"
}