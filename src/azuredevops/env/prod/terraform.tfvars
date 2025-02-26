# general
prefix    = "fat"
env_short = "p"
location  = "italynorth"

# azuredevops
project_name_prefix = "fatturazione"

# azure existing resources
key_vault_name    = "fat-p-kv"
key_vault_rg_name = "fat-p-kv-rg"
dns_zone_rg_name  = "fat-p-networking-rg"
identity_rg_name  = "fat-p-identity-rg"

# domains to manage
domains = [
  {
    dns_zone_name   = "portalefatturazione.pagopa.it"
    dns_record_name = "" # empty, APEX certificate
  },
  {
    dns_zone_name   = "portalefatturazione.pagopa.it"
    dns_record_name = "api"
  },
]

# pipeline for syncing azdo repo to github 
repos_to_sync = [
  {
    organization = "pagopa"
    name         = "portale-fatturazione-be"
    branch_name  = "refs/heads/main"
    yml_path     = ".devops/sync-github.yml"
  },
  # {
  #   organization = "pagopa"
  #   name         = "portale-fatturazione-fe"
  #   branch_name  = "refs/heads/main"
  #   yml_path     = ".devops/sync-github.yml"
  # },
  # {
  #   organization = "pagopa"
  #   name         = "portale-fatturazione-synapse"
  #   branch_name  = "refs/heads/main"
  #   yml_path     = ".devops/sync-github.yml"
  # },
]
