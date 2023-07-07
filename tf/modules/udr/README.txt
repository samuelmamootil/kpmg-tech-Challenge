Terraform module to create Azure UDR

Authors
samuel.rajumamootil@hm.com

How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#-----------------------------------------------------------------------------
module "routetable" {
  source              = "../../module/udr"
  resource_group_name = "myapp"
  location            = "westus"
  route_prefixes      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  route_nexthop_types = ["VirtualAppliance", "VnetLocal", "VnetLocal"]
  route_names         = ["route1", "route2", "route3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}