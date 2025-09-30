#
# Primary VNET in region Italy North
#

# primary vnet
resource "azurerm_virtual_network" "primary" {
  name                = "${local.project}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = var.cidr_vnet

  tags = var.tags

  lifecycle {
    # ddos managed by policy
    ignore_changes = [ddos_protection_plan]
  }
}

# pvt endpoint snet on primary
resource "azurerm_subnet" "private_endpoint" {
  name                              = "${local.project}-private_endpoint-snet"
  address_prefixes                  = var.cidr_pvt_endp_snet
  resource_group_name               = azurerm_virtual_network.primary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.primary.name
  private_endpoint_network_policies = "Disabled"
}


# subnet for the app gateway
resource "azurerm_subnet" "agw" {
  name                              = "${local.project}-agw-snet"
  address_prefixes                  = var.cidr_agw_snet
  resource_group_name               = azurerm_virtual_network.primary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.primary.name
  private_endpoint_network_policies = "Enabled"
  service_endpoints                 = ["Microsoft.Web"]
}

# subnet for the app (app service virtual network integration)
resource "azurerm_subnet" "app" {
  name                              = "${local.project}-app-snet"
  address_prefixes                  = var.cidr_app_snet
  resource_group_name               = azurerm_virtual_network.primary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.primary.name
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "default"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# subnet for the vpn gateway
resource "azurerm_subnet" "vpn" {
  count = var.vpn_enabled ? 1 : 0

  name                              = "GatewaySubnet" # vpn_gateway quirk, this is expected
  address_prefixes                  = var.cidr_vpn_snet
  resource_group_name               = azurerm_virtual_network.primary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.primary.name
  private_endpoint_network_policies = "Enabled"
}

# subnet for the dns forwarder
resource "azurerm_subnet" "dns_fwd" {
  count = var.vpn_enabled ? 1 : 0

  name                              = "${local.project}-dns-fwd-snet"
  address_prefixes                  = var.cidr_dns_fwd_snet
  resource_group_name               = azurerm_virtual_network.primary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.primary.name
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups" # delegate to this service
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
