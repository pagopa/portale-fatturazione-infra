#
# General
#
env_short      = "d"
env            = "dev"
prefix         = "fat"
adgroup_prefix = "fatturazione"

tags = {
  CreatedBy   = "Terraform"
  Environment = "DEV"
  Owner       = "PagoPA ICT"
  Source      = "https://github.com/pagopa/portale-fatturazione-infra"
  CostCenter  = "TS230 - PagoPA ICT"
}

#
# dns
#
dns_zone_portalefatturazione_prefix = "dev.portalefatturazione"

#
# appgateway
#
agw_sku         = "Basic"
agw_waf_enabled = false
agw_autoscale   = false

#
# appservice
#
app_plan_sku_name               = "B2"
app_plan_zone_balancing_enabled = false
app_staging_slot_enabled        = false

#
# azure sql
#
sql_database_sku_name = "S2"

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


#
# synapse
#
syn_spark_version = "3.4"

#
# feature flags
#
function_app_integration_enabled = true
alert_sdi_code_enabled           = false
grafana_enabled                  = false

#
# integration
#
send_api_url = "https://api.dev.notifichedigitali.it"
