#
# General
#
env_short      = "p"
env            = "prod"
prefix         = "fat"
adgroup_prefix = "fatturazione"
location       = "italynorth"
location_short = "itn"

tags = {
  CreatedBy   = "Terraform"
  Environment = "PROD"
  Owner       = "PagoPA ICT"
  Source      = "https://github.com/pagopa/portale-fatturazione-infra"
  CostCenter  = "TS230 - PagoPA ICT"
}

#
# DNS
#
dns_zone_portalefatturazione_prefix = "portalefatturazione"