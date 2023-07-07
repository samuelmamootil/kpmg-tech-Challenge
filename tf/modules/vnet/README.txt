Terraform modules directory
How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#-----------------------------------------------------------------------------
  resource_group_name        = "rg-demo-project-shared-westeurope-001"
  vnet_name                  = "vnet-${var.app_name}-${var.short_location}-${var.env_name}-001"
  location                   = "westeurope" 
  address_space              = ["10.0.0.0/24]
  dns_servers                = ["10.0.0.5"]

  
 tags = {
        #ProjectName  = "demo-project"
        #Env          = "dev"
        #Owner        = "user@example.com"
        #BusinessUnit = "CORP"
        #ServiceClass = "Gold"
 }
}