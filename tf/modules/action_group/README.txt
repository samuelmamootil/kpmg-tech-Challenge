How to use ?

#-----------------------------------------------------------------------------
#                               Example                                      #
#----------------------------------------------------------------------------- 
 
module "monitor_action_groups" {
  source              = "../../modules/action_group"
  for_each            = var.monitor_action_groups
  name                = each.value.action_group_name
  settings            = each.value
  resource_group_name = each.value.resource_group_name
}


monitor_action_groups = {
  example = {
    action_group_name  = "example-ag-name"
    resource_group_key = "example"
    shortname          = "example"

    email_receiver = {
      email_alert1 = {
        name                    = "email_alert_servicehealth_me"
        email_address           = "email1@domain"
        use_common_alert_schema = false
      } #remove the following block if additional email alerts aren't needed.
      email_alert2 = {
        name                    = "email_alert_servicehealth_somoneelse"
        email_address           = "email2@domain"
        use_common_alert_schema = false
      }}

    #more alert settings can be dynamically added/removed by commenting in/out the following blocks
    sms_receiver = {
      sms_alert1 = {
        name         = "sms_alert_servicehealth"
        country_code = "65"
        phone_number = "0000000"
      }
    }

    webhook_receiver = {
      webhook1 = {
        name        = "webhook_trigger_servicehealth"
        service_uri = "https://uri"
      }
    }
    arm_role_receiver = {
      role_alert1 = {
        name                    = "servicehealth-alerts-contributors"
        use_common_alert_schema = false
        role_name               = "Contributor" #case-sensitive
      }
      role_alert2 = {
        name                    = "servicehealth-alerts-owners"
        use_common_alert_schema = false
        role_name               = "Owner" #case-sensitive
      }
    }

  }
}