resource "azurerm_resource_group" "networking" {
  name     = "${local.project}-networking-rg"
  location = var.location
}
