
variable "resource_group_name" {
  description = "The name of an existing resource group to be imported."
  type        = string
}

variable "location" {
  description = "Location where Vnet will be deployed in"
  type        = string
}

variable "vnet_name" {
  description = "Location where Vnet will be deployed in"
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default = ["10.194.18.100",
    "10.194.18.101",
    "10.61.100.101",
    "10.61.100.102",
  "10.64.0.160"]
}

#variable "tags" {
#description = "The tags to associate with your network and subnets."
#type        = map(string)
#}

