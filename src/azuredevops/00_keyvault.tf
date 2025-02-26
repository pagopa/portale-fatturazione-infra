
data "azurerm_key_vault" "this" {
  resource_group_name = var.key_vault_rg_name
  name                = var.key_vault_name
}

module "secret_core" {
  source = "github.com/pagopa/terraform-azurerm-v3//key_vault_secrets_query?ref=v8.46.0"

  resource_group = data.azurerm_key_vault.this.resource_group_name
  key_vault_name = data.azurerm_key_vault.this.name

  secrets = concat(
    [local.github_readonly_token_name],
    # if we have some repos to sync to github, we'll need also rw token
    length(var.repos_to_sync) > 0 ? [local.github_readwrite_token_name] : []
  )
}
