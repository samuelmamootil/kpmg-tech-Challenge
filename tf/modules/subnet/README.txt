Terraform module to create Azure Subnet.

How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#-----------------------------------------------------------------------------

  name                 = "snet-private-endoints-example"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
   service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]  
  enforce_private_link_endpoint_network_policies = true