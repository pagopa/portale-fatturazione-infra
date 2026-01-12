#
# general
#
env_short      = "u"
env            = "uat"
prefix         = "fat"
adgroup_prefix = "fatturazione"

tags = {
  CreatedBy   = "Terraform"
  Environment = "UAT"
  Owner       = "PagoPA ICT"
  Source      = "https://github.com/pagopa/portale-fatturazione-infra"
  CostCenter  = "TS230 - PagoPA ICT"
}

#
# dns
#
dns_zone_portalefatturazione_prefix = "uat.portalefatturazione"

#
# appgateway
#
agw_sku         = "Standard_v2"
agw_waf_enabled = false

#
# appservice
#
app_plan_sku_name = "P0v3"

#
# azure sql
#
sql_database_sku_name    = "HS_S_Gen5_4"
sql_database_max_size_gb = null # hyperscale

#
# storage
#
storage_sa_rule_ips = [
  "18.159.227.69",
  "18.192.147.151",
  "3.126.198.129",
  "93.42.64.143" # unknown ip
]

storage_sap_rule_ips = [
  "18.193.21.232",
  "18.197.134.65",
  "18.198.196.89",
  "3.65.9.91",
  "3.66.249.150",
  "3.67.182.154",
  "3.67.255.232",
  "3.68.44.236",
  "52.29.190.137",
  "93.42.64.143",
  "93.63.219.230",
]

crm_storage_id = "/subscriptions/57cfa745-48f4-4ad8-91ab-fb63aebc57ec/resourceGroups/crm-u-data-rg/providers/Microsoft.Storage/storageAccounts/crmudatast"

#
# synapse
#
syn_spark_version = "3.4"

#
# feature flags
#
function_app_integration_enabled = true

#
# integration
#
send_api_url = "https://api.uat.notifichedigitali.it"
