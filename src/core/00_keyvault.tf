
data "azurerm_key_vault" "main" {
  name                = "${local.project}-kv"
  resource_group_name = data.azurerm_resource_group.kv.name
}

data "azurerm_key_vault" "app" {
  name                = "${local.project}-kv-app"
  resource_group_name = data.azurerm_resource_group.kv.name
}

