Terraform module to create Azure Private Endpoint.

Authors
samuel.rajumamootil@hm.com

How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#-----------------------------------------------------------------------------

module "private_endpoint" {
  source  = "../../module/private_endpoint"
  version = "1.0.0"
  
  resource_group_name = "resourceGroup"
  endpoint_resource_id = "id_of_the_resource-to-assign-PE-to"
  
  network = {
    resource_group_name = "vnet_resourcegroup"
    vnet_name           = "vnet_name" 
    subnet_name         = "subnetName-fortheNewPE" 
  }  
  
  dns = {
    zone_ids   = ["/subscriptions/787ytdg-foo-bar-id/resourceGroups/network/providers/Microsoft.Network/privateDnsZones/private.blob.zone"]
    zone_name  = "private.blob.zone"
  }
}