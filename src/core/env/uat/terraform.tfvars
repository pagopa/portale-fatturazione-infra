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
# networking
#
cidr_vnet          = ["10.0.0.0/18"]
cidr_agw_snet      = ["10.0.0.0/24"]
cidr_app_snet      = ["10.0.1.0/24"]
cidr_synapse_snet  = ["10.0.2.0/24"]
cidr_hsql_snet     = ["10.0.3.0/24"]
cidr_pvt_endp_snet = ["10.0.60.0/23"]
cidr_dns_fwd_snet  = ["10.0.62.248/29"] # we want 3 IPs only on this subnet (5 are reserved by Azure)
cidr_vpn_snet      = ["10.0.63.0/24"]

#
# secondary networking
#
secondary_cidr_vnet          = ["10.1.0.0/18"]
secondary_cidr_pvt_endp_snet = ["10.1.60.0/23"]

#
# ddos protection
#
ddos_protection_plan = {
  id     = "/subscriptions/0da48c97-355f-4050-a520-f11a18b8be90/resourceGroups/sec-p-ddos/providers/Microsoft.Network/ddosProtectionPlans/sec-p-ddos-protection"
  enable = true
}

#
# appgateway
#
agw_sku                          = "Standard_v2"
agw_waf_enabled                  = false
agw_apex_app_certificate_name    = "uat-portalefatturazione-pagopa-it"
agw_api_app_certificate_name     = "api-uat-portalefatturazione-pagopa-it"
agw_storage_certificate_name     = "storage-uat-portalefatturazione-pagopa-it"
agw_integration_certificate_name = "integration-uat-portalefatturazione-pagopa-it"

#
# appservice
#
app_plan_sku_name = "P0v3"

#
# azure sql
#
sql_database_sku_name = "S3"

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
