#
# Secondary VNET in region Europe West
#

# secondary vnet
resource "azurerm_virtual_network" "secondary" {
  name                = "${local.project}-secondary-vnet"
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = var.secondary_cidr_vnet

  tags = var.tags

  lifecycle {
    # ddos managed by policy
    ignore_changes = [ddos_protection_plan]
  }
}

# pvt endpoint snet on secondary
resource "azurerm_subnet" "private_endpoint_secondary" {
  name                              = "${local.project}-private_endpoint-snet"
  address_prefixes                  = var.secondary_cidr_pvt_endp_snet
  resource_group_name               = azurerm_virtual_network.secondary.resource_group_name
  virtual_network_name              = azurerm_virtual_network.secondary.name
  private_endpoint_network_policies = "Disabled"
}

# peering between vnets
module "vnet_peering_between_primary_secondary" {
  source                           = "./.terraform/modules/__v4__/virtual_network_peering/"
  source_resource_group_name       = azurerm_resource_group.networking.name
  source_virtual_network_name      = azurerm_virtual_network.primary.name
  source_remote_virtual_network_id = azurerm_virtual_network.primary.id
  source_allow_gateway_transit     = true # needed by vpn gateway for enabling routing from vnet to vnet_integration
  target_resource_group_name       = azurerm_resource_group.networking.name
  target_virtual_network_name      = azurerm_virtual_network.secondary.name
  target_remote_virtual_network_id = azurerm_virtual_network.secondary.id
  target_use_remote_gateways       = true # needed by vpn gateway for enabling routing from vnet to vnet_integration
}
