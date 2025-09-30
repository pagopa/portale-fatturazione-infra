data "azurerm_resource_group" "networking" {
  name = format("%s-%s-rg", local.project, "networking")
}

data "azurerm_resource_group" "app" {
  name = format("%s-%s-rg", local.project, "app")
}

data "azurerm_resource_group" "kv" {
  name = format("%s-%s-rg", local.project, "kv")
}

data "azurerm_resource_group" "analytics" {
  name = format("%s-%s-rg", local.project, "analytics")
}

data "azurerm_resource_group" "monitoring" {
  name = format("%s-%s-rg", local.project, "monitoring")
}

# data "azurerm_resource_group" "identity" {
#   name = format("%s-%s-rg", local.project, "identity")
# }
