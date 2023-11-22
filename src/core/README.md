<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | <= 2.43.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.76.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.43.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.71.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module___v3__"></a> [\_\_v3\_\_](#module\_\_\_v3\_\_) | git::https://github.com/pagopa/terraform-azurerm-v3.git | d97d51148b02eb3225507eeef2ec25d52f4f343b |
| <a name="module_agw"></a> [agw](#module\_agw) | ./.terraform/modules/__v3__/app_gateway/ | n/a |
| <a name="module_agw_snet"></a> [agw\_snet](#module\_agw\_snet) | ./.terraform/modules/__v3__/subnet/ | n/a |
| <a name="module_app"></a> [app](#module\_app) | ./.terraform/modules/__v3__/app_service/ | n/a |
| <a name="module_app_snet"></a> [app\_snet](#module\_app\_snet) | ./.terraform/modules/__v3__/subnet/ | n/a |
| <a name="module_dls_storage"></a> [dls\_storage](#module\_dls\_storage) | ./.terraform/modules/__v3__/storage_account/ | n/a |
| <a name="module_dns_fwd"></a> [dns\_fwd](#module\_dns\_fwd) | ./.terraform/modules/__v3__/dns_forwarder/ | n/a |
| <a name="module_dns_fwd_snet"></a> [dns\_fwd\_snet](#module\_dns\_fwd\_snet) | ./.terraform/modules/__v3__/subnet/ | n/a |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ./.terraform/modules/__v3__/key_vault/ | n/a |
| <a name="module_private_endpoint_snet"></a> [private\_endpoint\_snet](#module\_private\_endpoint\_snet) | ./.terraform/modules/__v3__/subnet/ | n/a |
| <a name="module_sa_storage"></a> [sa\_storage](#module\_sa\_storage) | ./.terraform/modules/__v3__/storage_account/ | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ./.terraform/modules/__v3__/virtual_network/ | n/a |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ./.terraform/modules/__v3__/vpn_gateway/ | n/a |
| <a name="module_vpn_snet"></a> [vpn\_snet](#module\_vpn\_snet) | ./.terraform/modules/__v3__/subnet/ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.application_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_dns_a_record.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_caa_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_ns_record.dev_portalefatturazione_pagopa_it_ns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ns_record) | resource |
| [azurerm_dns_zone.portalefatturazione](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_key_vault_access_policy.ad_group_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.adgroup_developers_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.adgroup_externals_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.adgroup_security_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.agw_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_log_analytics_workspace.log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_mssql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_dns_zone.privatelink_azurewebsites_net](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_database_windows_net](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privatelink_azurewebsites_net_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privatelink_database_windows_net_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_public_ip.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.analytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.networking](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_container.dls_raw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.dls_synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.sa_pfat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_synapse_spark_pool.sparkcls01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) | resource |
| [azurerm_user_assigned_identity.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_application.vpn_app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) | data source |
| [azuread_group.adgroup_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.adgroup_developers](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.adgroup_externals](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.adgroup_security](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_user.administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.pillar](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_certificate.agw_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate) | data source |
| [azurerm_key_vault_secret.administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.pillar](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adgroup_prefix"></a> [adgroup\_prefix](#input\_adgroup\_prefix) | prefix of the ad group name | `string` | n/a | yes |
| <a name="input_agw_app_certificate_name"></a> [agw\_app\_certificate\_name](#input\_agw\_app\_certificate\_name) | the certificate name on the kv for the api endpoint | `string` | n/a | yes |
| <a name="input_app_plan_sku_name"></a> [app\_plan\_sku\_name](#input\_app\_plan\_sku\_name) | the name of the app plan sku | `string` | `"B1"` | no |
| <a name="input_cidr_agw_snet"></a> [cidr\_agw\_snet](#input\_cidr\_agw\_snet) | cidr of the appgateway subnet | `list(string)` | n/a | yes |
| <a name="input_cidr_app_snet"></a> [cidr\_app\_snet](#input\_cidr\_app\_snet) | cidr of the appservice subnet | `list(string)` | n/a | yes |
| <a name="input_cidr_dns_fwd_snet"></a> [cidr\_dns\_fwd\_snet](#input\_cidr\_dns\_fwd\_snet) | cidr of the dns forwarder subnet | `list(string)` | n/a | yes |
| <a name="input_cidr_hsql_snet"></a> [cidr\_hsql\_snet](#input\_cidr\_hsql\_snet) | cidr of the hyperscale sql subnet | `list(string)` | n/a | yes |
| <a name="input_cidr_pvt_endp_snet"></a> [cidr\_pvt\_endp\_snet](#input\_cidr\_pvt\_endp\_snet) | cidr of the private endpoints subnet (all here) | `list(string)` | n/a | yes |
| <a name="input_cidr_synapse_snet"></a> [cidr\_synapse\_snet](#input\_cidr\_synapse\_snet) | cidr of the synapse subnet | `list(string)` | n/a | yes |
| <a name="input_cidr_vnet"></a> [cidr\_vnet](#input\_cidr\_vnet) | cidr of the vnet | `list(string)` | n/a | yes |
| <a name="input_cidr_vpn_snet"></a> [cidr\_vpn\_snet](#input\_cidr\_vpn\_snet) | cidr of the vpn subnet | `list(string)` | n/a | yes |
| <a name="input_dns_default_ttl_sec"></a> [dns\_default\_ttl\_sec](#input\_dns\_default\_ttl\_sec) | dns ttl | `number` | `3600` | no |
| <a name="input_dns_external_domain"></a> [dns\_external\_domain](#input\_dns\_external\_domain) | root dns zone name (external) | `string` | `"pagopa.it"` | no |
| <a name="input_dns_zone_portalefatturazione_prefix"></a> [dns\_zone\_portalefatturazione\_prefix](#input\_dns\_zone\_portalefatturazione\_prefix) | dns zone name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | n/a | `string` | n/a | yes |
| <a name="input_kv_sku_name"></a> [kv\_sku\_name](#input\_kv\_sku\_name) | name of the keyvault sku | `string` | `"standard"` | no |
| <a name="input_kv_soft_delete_retention_days"></a> [kv\_soft\_delete\_retention\_days](#input\_kv\_soft\_delete\_retention\_days) | number of days before keys are removed (soft delete) | `number` | `30` | no |
| <a name="input_law_daily_quota_gb"></a> [law\_daily\_quota\_gb](#input\_law\_daily\_quota\_gb) | daily quota in gb of the log analytics workspace (default: -1, unlimited) | `number` | `-1` | no |
| <a name="input_law_retention_in_days"></a> [law\_retention\_in\_days](#input\_law\_retention\_in\_days) | retention in days of the log analytics workspace | `number` | `30` | no |
| <a name="input_law_sku"></a> [law\_sku](#input\_law\_sku) | the name of the log analytics workspace sku | `string` | `"PerGB2018"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"italynorth"` | no |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | location short like eg: neu, weu.. | `string` | `"itn"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | n/a | `string` | `"westeurope"` | no |
| <a name="input_secondary_location_short"></a> [secondary\_location\_short](#input\_secondary\_location\_short) | location short like eg: neu, weu.. | `string` | `"weu"` | no |
| <a name="input_sql_database_max_size_gb"></a> [sql\_database\_max\_size\_gb](#input\_sql\_database\_max\_size\_gb) | the max size in gb of the database | `number` | `250` | no |
| <a name="input_sql_database_sku_name"></a> [sql\_database\_sku\_name](#input\_sql\_database\_sku\_name) | the name of the database sku | `string` | `"S0"` | no |
| <a name="input_sql_version"></a> [sql\_version](#input\_sql\_version) | the required version of the sql server | `string` | `"12.0"` | no |
| <a name="input_storage_delete_retention_days"></a> [storage\_delete\_retention\_days](#input\_storage\_delete\_retention\_days) | blob and container retention days on (soft) delete | `number` | `30` | no |
| <a name="input_syn_spark_version"></a> [syn\_spark\_version](#input\_syn\_spark\_version) | the required version of the spark cluster | `string` | `"3.3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
