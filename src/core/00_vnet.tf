#
# Primary
#

# primary vnet
data "azurerm_virtual_network" "primary" {
  name                = "${local.project}-vnet"
  resource_group_name = data.azurerm_resource_group.networking.name
}

# pvt endpoint snet on primary
data "azurerm_subnet" "private_endpoint" {
  name                 = "${local.project}-private_endpoint-snet"
  resource_group_name  = data.azurerm_virtual_network.primary.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.primary.name
}

data "azurerm_subnet" "agw" {
  name                 = "${local.project}-agw-snet"
  resource_group_name  = data.azurerm_virtual_network.primary.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.primary.name
}

data "azurerm_subnet" "app" {
  name                 = "${local.project}-app-snet"
  resource_group_name  = data.azurerm_virtual_network.primary.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.primary.name
}


#
# Secondary
#

# secondary vnet
data "azurerm_virtual_network" "secondary" {
  name                = "${local.project}-secondary-vnet"
  resource_group_name = data.azurerm_resource_group.networking.name
}

# pvt endpoint snet on secondary
data "azurerm_subnet" "private_endpoint_secondary" {
  name                 = "${local.project}-private_endpoint-snet"
  resource_group_name  = data.azurerm_virtual_network.secondary.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.secondary.name
}
