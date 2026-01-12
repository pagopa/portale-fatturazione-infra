
data "azurerm_resource_group" "identity" {
  name = "${local.project}-identity-rg"
}

data "azurerm_resource_group" "dns" {
  name = "${local.project}-networking-rg"
}

data "azurerm_resource_group" "keyvault" {
  name = "${local.project}-kv-rg"
}
