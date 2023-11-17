resource "azurerm_resource_group" "networking" {
  name     = format("%s-%s-rg", local.project, "networking")
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "app" {
  name     = format("%s-%s-rg", local.project, "app")
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "kv" {
  name     = format("%s-%s-rg", local.project, "kv")
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "analytics" {
  name     = format("%s-%s-rg", local.project, "analytics")
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = format("%s-%s-rg", local.project, "monitoring")
  location = var.location
  tags     = var.tags
}