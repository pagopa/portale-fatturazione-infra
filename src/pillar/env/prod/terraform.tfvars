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
vpn_gw_sku                   = "VpnGw1AZ"
