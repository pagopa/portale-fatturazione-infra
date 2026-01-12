# general
prefix    = "fat"
env_short = "d"
location  = "italynorth"

# azuredevops
project_name_prefix = "fatturazione"

# domains to manage
domains = [
  {
    dns_zone_name   = "dev.portalefatturazione.pagopa.it"
    dns_record_name = "" # empty, APEX certificate
  },
  {
    dns_zone_name   = "dev.portalefatturazione.pagopa.it"
    dns_record_name = "api"
  },
  {
    dns_zone_name   = "dev.portalefatturazione.pagopa.it"
    dns_record_name = "storage"
  },
  {
    dns_zone_name   = "dev.portalefatturazione.pagopa.it"
    dns_record_name = "integration"
  },
]
