# Portale Fatturazione Infra - Azure DevOps

Terraform scripts for applying Portale Fatturazione infrastructure regarding Azure DevOps.

## Automatic TLS certificate rotation

TLS certificates for Portale Fatturazione domains are automatically
renewed via ACME on Let's Encrypt.  This duty is performed by an Azure
Devops pipeline. Read the folling article for more:
https://medium.com/pagopa-spa/certificati-https-come-gestirli-con-un-approccio-infrastructure-as-code-8ee0abc03664
The main difference from that article is that we use a more recent
version that employs managed identity with federated credentials
instead of service principals with keys.

One set of pipelines (one per domain) is managed for each Azure
environment in the same Azure DevOps environment (in fact, we don't
have environments in Azure DevOps).

## Sync Azure DevOps repos to GitHub repos

Some repos where created on Azure DevOps for historical reasons and
are still managed there.  We provide here a pipeline that mirrors
those repos to GitHub.

This is obviously not environment-dependent, so we just manage it in
`prod` env.

## How to

### Add a new domain

Domain is in every environment so:

`env/uat/terraform.tfvars`
```diff
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
  + {
  +   dns_zone_name   = "mynewzone.pagopa.it"
  +   dns_record_name = "mynewsubdomain"
  + },
]
```

`env/prod/terraform.tfvars`
```diff
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
  + {
  +   dns_zone_name   = "uat.mynewzone.pagopa.it"
  +   dns_record_name = "mynewsubdomain"
  + },
]
```

### Add a new repo to be synced

Prod-only:

`env/prod/terraform.tfvars`
```diff
# pipeline for syncing azdo repo to github 
repos_to_sync = [
  {
    organization = "pagopa"
    name         = "portale-fatturazione-be"
    branch_name  = "refs/heads/main"
    yml_path     = ".devops/sync-github.yml"
  },
  +  {
  +   organization = "pagopa"
  +   name         = "portale-fatturazione-fe"
  +   branch_name  = "refs/heads/main"
  +   yml_path     = ".devops/sync-github.yml"
  + },
]
```

In the example above, the `yml_path` contains the path for a pipeline
definition that is to be found in the synced repo.

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.6 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.53.1 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.116.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_letsencrypt_credential"></a> [letsencrypt\_credential](#module\_letsencrypt\_credential) | github.com/pagopa/terraform-azurerm-v3//letsencrypt_credential | v8.46.0 |
| <a name="module_secret_core"></a> [secret\_core](#module\_secret\_core) | github.com/pagopa/terraform-azurerm-v3//key_vault_secrets_query | v8.46.0 |
| <a name="module_tls_cert_service_conn"></a> [tls\_cert\_service\_conn](#module\_tls\_cert\_service\_conn) | github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_federated | v9.2.1 |
| <a name="module_tlscert_renewal_pipeline"></a> [tlscert\_renewal\_pipeline](#module\_tlscert\_renewal\_pipeline) | github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert_federated | v9.2.1 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_build_definition.sync_repo_to_github](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) | resource |
| [azuredevops_serviceendpoint_github.github_ro](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_github) | resource |
| [azurerm_key_vault_access_policy.tls_cert_service_conn_kv_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azuredevops_git_repository.repo](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/git_repository) | data source |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_expire_seconds"></a> [cert\_expire\_seconds](#input\_cert\_expire\_seconds) | Renew certificate if it expires in this interval. Defaults to 30 days | `number` | `2592000` | no |
| <a name="input_dns_zone_rg_name"></a> [dns\_zone\_rg\_name](#input\_dns\_zone\_rg\_name) | DNS zones resource group name | `string` | n/a | yes |
| <a name="input_domains"></a> [domains](#input\_domains) | Domains to manage regarding TLS certifcates | <pre>list(object({<br/>    dns_zone_name   = string<br/>    dns_record_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | n/a | `string` | n/a | yes |
| <a name="input_identity_rg_name"></a> [identity\_rg\_name](#input\_identity\_rg\_name) | Identities resource group name | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key Vault name | `string` | n/a | yes |
| <a name="input_key_vault_rg_name"></a> [key\_vault\_rg\_name](#input\_key\_vault\_rg\_name) | Key Vault resource group name | `string` | n/a | yes |
| <a name="input_le_acme_tiny_repository"></a> [le\_acme\_tiny\_repository](#input\_le\_acme\_tiny\_repository) | Repository of the Let's Encrypt ACME script | <pre>object({<br/>    organization   = string<br/>    name           = string<br/>    branch_name    = string<br/>    pipelines_path = string<br/>  })</pre> | <pre>{<br/>  "branch_name": "refs/heads/master",<br/>  "name": "le-azure-acme-tiny",<br/>  "organization": "pagopa",<br/>  "pipelines_path": "."<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_project_name_prefix"></a> [project\_name\_prefix](#input\_project\_name\_prefix) | Prefix of the azure devops project | `string` | n/a | yes |
| <a name="input_repos_to_sync"></a> [repos\_to\_sync](#input\_repos\_to\_sync) | Repositories to sync to GitHub | <pre>list(object({<br/>    organization = string<br/>    name         = string<br/>    branch_name  = string<br/>    yml_path     = string<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
