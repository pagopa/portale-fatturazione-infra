
module "secret_core" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3//key_vault_secrets_query?ref=v7.20.0"
  providers = {
    azurerm = azurerm.prod
  }

  resource_group = local.prod.key_vault_rg_name
  key_vault_name = local.prod.key_vault_name

  secrets = [
    "azure-devops-github-ro-TOKEN",
  ]
}

# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "azure-devops-github-ro" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "azure-devops-github-ro"
  auth_personal {
    personal_access_token = module.secret_core.values["azure-devops-github-ro-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}
