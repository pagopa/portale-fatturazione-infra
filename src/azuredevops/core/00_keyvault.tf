# data "azurerm_key_vault" "kv_dev" {
#   provider = azurerm.dev

#   resource_group_name = local.dev.key_vault_rg_name
#   name                = local.dev.key_vault_name
# }

data "azurerm_key_vault" "kv_uat" {
  provider = azurerm.uat

  resource_group_name = local.uat.key_vault_rg_name
  name                = local.uat.key_vault_name
}

data "azurerm_key_vault" "kv_prod" {
  provider = azurerm.prod

  resource_group_name = local.prod.key_vault_rg_name
  name                = local.prod.key_vault_name
}
