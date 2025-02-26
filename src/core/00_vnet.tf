# primary vnet
module "vnet" {
  source               = "./.terraform/modules/__v4__/virtual_network/"
  name                 = format("%s-vnet", local.project)
  location             = azurerm_resource_group.networking.location
  resource_group_name  = azurerm_resource_group.networking.name
  ddos_protection_plan = var.ddos_protection_plan
  address_space        = var.cidr_vnet
  tags                 = var.tags
}

# pvt endpoint snet on primary
module "private_endpoint_snet" {
  source                            = "./.terraform/modules/__v4__/subnet/"
  name                              = format("%s-%s-snet", local.project, "private_endpoint")
  address_prefixes                  = var.cidr_pvt_endp_snet
  resource_group_name               = azurerm_resource_group.networking.name
  virtual_network_name              = module.vnet.name
  private_endpoint_network_policies = "Disabled"
  service_endpoints                 = []
}

# secondary vnet
module "secondary_vnet" {
  source               = "./.terraform/modules/__v4__/virtual_network/"
  name                 = format("%s-secondary-vnet", local.project)
  location             = var.secondary_location
  resource_group_name  = azurerm_resource_group.networking.name
  ddos_protection_plan = var.ddos_protection_plan
  address_space        = var.secondary_cidr_vnet
  tags                 = var.tags
}

# pvt endpoint snet on secondary
module "private_endpoint_secondary_snet" {
  source                            = "./.terraform/modules/__v4__/subnet/"
  name                              = format("%s-%s-snet", local.project, "private_endpoint")
  address_prefixes                  = var.secondary_cidr_pvt_endp_snet
  resource_group_name               = azurerm_resource_group.networking.name
  virtual_network_name              = module.secondary_vnet.name
  private_endpoint_network_policies = "Disabled"
  service_endpoints                 = []
}

# peering between vnets
module "vnet_peering_between_primary_secondary" {
  source                           = "./.terraform/modules/__v4__/virtual_network_peering/"
  source_resource_group_name       = azurerm_resource_group.networking.name
  source_virtual_network_name      = module.vnet.name
  source_remote_virtual_network_id = module.vnet.id
  source_allow_gateway_transit     = true # needed by vpn gateway for enabling routing from vnet to vnet_integration
  target_resource_group_name       = azurerm_resource_group.networking.name
  target_virtual_network_name      = module.secondary_vnet.name
  target_remote_virtual_network_id = module.secondary_vnet.id
  target_use_remote_gateways       = true # needed by vpn gateway for enabling routing from vnet to vnet_integration
}
