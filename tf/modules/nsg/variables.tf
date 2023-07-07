variable "nsg_name" {
  description = "List of network rules to apply to network interface."
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "(Required) The name of an existing resource group to be imported."
  type        = string
}

variable "nsgrules" {
  description = "Security rules for the network security group using this format name = [priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix, description]"
  # type = map(object({
  #   direction                  = string
  #   priority                   = string,
  #   access                     = string,
  #   protocol                   = string,
  #   source_port_range          = string,
  #   destination_port_range     = string,
  #   source_address_prefix      = string,
  #   destination_address_prefix = string
  # }))


  default = null
}

variable "workspace_id" {
  type = string
}