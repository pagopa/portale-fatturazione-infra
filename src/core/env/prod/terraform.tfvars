#
# general
#
env_short      = "p"
env            = "prod"
prefix         = "fat"
adgroup_prefix = "fatturazione"

tags = {
  CreatedBy   = "Terraform"
  Environment = "PROD"
  Owner       = "PagoPA ICT"
  Source      = "https://github.com/pagopa/portale-fatturazione-infra"
  CostCenter  = "TS230 - PagoPA ICT"
}

#
# dns
#
dns_zone_portalefatturazione_prefix = "portalefatturazione"

#
# appgateway
#
agw_sku         = "WAF_v2"
agw_waf_enabled = true

#
# appservice
#
app_plan_sku_name = "P1v3"

#
# azure sql
#
sql_database_sku_name    = "HS_S_Gen5_8"
sql_database_max_size_gb = null # hyperscale
sql_database_read_scale  = true

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
  "93.63.219.234",
]

storage_dls_rule_ips = [
  "18.159.227.69",
  "18.192.147.151",
  "3.126.198.129",
]

crm_storage_id = "/subscriptions/59f48fac-dfdb-4063-bcc6-9322c9e5ebd0/resourceGroups/crm-p-data-rg/providers/Microsoft.Storage/storageAccounts/crmpdatast"

#
# synapse
#
syn_spark_version = "3.4"

#
# integration
#
send_api_url = "https://api.notifichedigitali.it"
