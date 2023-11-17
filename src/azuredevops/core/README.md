# Portale Fatturazione Infra - Azure DevOps

Terraform scripts for applying Portale Fatturazione infrastructure on Azure DevOps.
This infrastructure consists in pipelines and service connections for automatic
TLS certificate rotation with ACME.

Managed certificates are for hosts `dev.portalefatturazione.pagopa.it` and `portalefatturazione.pagopa.it`.

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.30.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >= 0.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.71.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 0.10.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.53.0 |
| <a name="provider_azurerm.prod"></a> [azurerm.prod](#provider\_azurerm.prod) | 3.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_letsencrypt_prod"></a> [letsencrypt\_prod](#module\_letsencrypt\_prod) | git::https://github.com/pagopa/terraform-azurerm-v3//letsencrypt_credential | v7.20.0 |
| <a name="module_secret_core"></a> [secret\_core](#module\_secret\_core) | git::https://github.com/pagopa/terraform-azurerm-v3//key_vault_secrets_query | v7.20.0 |
| <a name="module_tls_cert_service_conn_prod"></a> [tls\_cert\_service\_conn\_prod](#module\_tls\_cert\_service\_conn\_prod) | git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_federated | v4.0.0 |
| <a name="module_tlscert-portalefatturazione-pagopa-it-cert_az"></a> [tlscert-portalefatturazione-pagopa-it-cert\_az](#module\_tlscert-portalefatturazione-pagopa-it-cert\_az) | git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert_federated | v4.1.1 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_serviceendpoint_github.azure-devops-github-ro](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_github) | resource |
| [azurerm_key_vault_access_policy.tls_cert_service_conn_kv_access_policy_prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.kv_prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subscriptions.dev](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscriptions) | data source |
| [azurerm_subscriptions.prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscriptions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dev_subscription_name"></a> [dev\_subscription\_name](#input\_dev\_subscription\_name) | DEV Subscription name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_prod-tlscert-portalefatturazione-pagopa-it"></a> [prod-tlscert-portalefatturazione-pagopa-it](#input\_prod-tlscert-portalefatturazione-pagopa-it) | n/a | `map` | <pre>{<br>  "pipeline": {<br>    "dns_record_name": "",<br>    "dns_zone_name": "portalefatturazione.pagopa.it",<br>    "enable_tls_cert": true,<br>    "path": "TLS-Certificates",<br>    "variables": {<br>      "CERT_NAME_EXPIRE_SECONDS": "2592000"<br>    },<br>    "variables_secret": {}<br>  },<br>  "repository": {<br>    "branch_name": "refs/heads/master",<br>    "name": "le-azure-acme-tiny",<br>    "organization": "pagopa",<br>    "pipelines_path": "."<br>  }<br>}</pre> | no |
| <a name="input_prod_dns_zone_rg_name"></a> [prod\_dns\_zone\_rg\_name](#input\_prod\_dns\_zone\_rg\_name) | PROD DNS Zone resource group name | `string` | n/a | yes |
| <a name="input_prod_key_vault_name"></a> [prod\_key\_vault\_name](#input\_prod\_key\_vault\_name) | PROD Key Vault name | `string` | n/a | yes |
| <a name="input_prod_key_vault_rg_name"></a> [prod\_key\_vault\_rg\_name](#input\_prod\_key\_vault\_rg\_name) | PROD Key Vault resource group name | `string` | n/a | yes |
| <a name="input_prod_subscription_name"></a> [prod\_subscription\_name](#input\_prod\_subscription\_name) | PROD Subscription name | `string` | n/a | yes |
| <a name="input_project_name_prefix"></a> [project\_name\_prefix](#input\_project\_name\_prefix) | Project name prefix (e.g. userregistry) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
