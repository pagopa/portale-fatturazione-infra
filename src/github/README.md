# Portale Fatturazione GitHub infrastructure

Terraform script for managing GitHub repos of Portale Fatturazione project.

## Configure or add repos

Modify file [terraform.tfvars](./env/prod/terraform.tfvars).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_environment.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [github_team.product_admin](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |
| [github_team.service_line_admin](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Name of the product or service these repos belong to | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Repositories to be managed | <pre>list(object({<br/>    name          = string<br/>    description   = string<br/>    visibility    = string<br/>    topics        = optional(set(string), null)<br/>    homepage_url  = optional(string, null)<br/>    from_template = optional(string, null)<br/>    is_template   = optional(bool, false)<br/>    archived      = optional(bool, false)<br/>    environments = optional(list(object({<br/>      name              = string<br/>      requires_approval = optional(bool, false)<br/>      variables         = optional(map(string), {})<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_service_line"></a> [service\_line](#input\_service\_line) | Name of the service line owner of these repos | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
