#
# CORE KEYVAULT
#

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
