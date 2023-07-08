variable "subnet_prefix" {
  description = "(Required) The address prefix that is used by the subnet."
  type        = list(string)
  default     = ["10.0.0.0/28"]
}

variable "service_endpoints" {
  description = "Private connection to azure resources using azure backbone network "
  type        = list(string)
  default     = []
}

variable "service_endpoint_policy_ids" {
  description = "The list of IDs of Service Endpoint Policies to associate with the subnet."
  type        = list(string)
  default     = null
}

variable "resource_group_name" {
  description = "(Required) The name of an existing resource group to be imported."
  type        = string
}

variable "vnet_name" {
  description = "(Required) The name of an existing virtual network to be imported."
  type        = string
}

variable "subnet_name" {
  description = "(Required) The name of the virtual network"
  default     = "cloud-subnet"
}

variable "nsg_name" {
  type = string
}

variable "enforce_private_link_endpoint_network_policies" {
  description = <<EOT
Enable or Disable network policies for the private link endpoint on the subnet.
Conflicts with enforce_private_link_service_network_policies.
EOT
  type        = bool
  default     = false
}

variable "enforce_private_link_service_network_policies" {
  description = <<EOT
Enable or Disable network policies for the private link service on the subnet.
Conflicts with enforce_private_link_endpoint_network_policies.
EOT
  type        = bool
  default     = false
}


#variable "tags" {
# description = "tags for subnet"
# type        = map(string)
#}