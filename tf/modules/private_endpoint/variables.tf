variable "location" {
  description = "The Azure region where the private Endpoint should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource group where the the Private Endpoint resource will be created."
  type        = string
}

variable "name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  description = "Id of Azure Virtual Network Subnet where Private Endpoint would be located."
  type        = string
}

variable "private_service_connection_name" {
  type = string
}

variable "endpoint_resource_id" {
  description = "The ID of the resource that the new Private Endpoint will be assigned to."
  type        = string
}

variable "private_dns_zone_name" {
  type = string
}

variable "subresource_names" {
  type    = list(string)
  default = null
}