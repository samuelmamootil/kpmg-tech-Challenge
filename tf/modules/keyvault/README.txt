Sandbox environment directory
How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#-----------------------------------------------------------------------------

# Resource Group and Key Vault pricing tier details
  resource_group_name        = "rg-demo-project-shared-westeurope-001"
  key_vault_name             = "demo-project-shard"
  key_vault_sku_pricing_tier = "premium"

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted (currently 90 days)
  # Once `Soft Delete` has been Enabled it's not possible to Disable it.
  enable_purge_protection = false
  enable_soft_delete      = false
  
  # Create a required Secrets as per your need.
  # When you Add `usernames` with empty password this module creates a strong random password 
  # use .tfvars file to manage the secrets as variables to avoid security issues. 
#secrets = {
    #"message" = "Hello, world!"
    #"vmpass"  = ""
  #}

#tags = {
    #ProjectName  = "demo-project"
    #Env          = "dev"
    #Owner        = "user@example.com"
    #BusinessUnit = "CORP"
    #ServiceClass = "Gold"
  #}
#}
