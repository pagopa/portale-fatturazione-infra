# general
prefix    = "fat"
env_short = "u"
location  = "italynorth"

# azuredevops
project_name_prefix = "fatturazione"

# azure existing resources
key_vault_name    = "fat-u-kv"
key_vault_rg_name = "fat-u-kv-rg"
dns_zone_rg_name  = "fat-u-networking-rg"
identity_rg_name  = "fat-u-identity-rg"

# domains to manage
domains = [
  {
    dns_zone_name   = "uat.portalefatturazione.pagopa.it"
    dns_record_name = "" # empty, APEX certificate
  },
  {
    dns_zone_name   = "uat.portalefatturazione.pagopa.it"
    dns_record_name = "api"
  },
]
