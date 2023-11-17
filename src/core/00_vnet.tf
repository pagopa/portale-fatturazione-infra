module "vnet" {
  source              = "./.terraform/modules/__v3__/virtual_network/"
  name                = format("%s-vnet", local.project)
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  # FIXME, move to variables
  ddos_protection_plan = {
    id     = "/subscriptions/0da48c97-355f-4050-a520-f11a18b8be90/resourceGroups/sec-p-ddos/providers/Microsoft.Network/ddosProtectionPlans/sec-p-ddos-protection"
    enable = true
  }
  address_space = var.cidr_vnet
  tags          = var.tags
}

module "private_endpoint_snet" {
  source                                    = "./.terraform/modules/v3/subnet/"
  name                                      = format("%s-%s-snet", local.project, "private_endpoint")
  address_prefixes                          = var.cidr_pvt_endp_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = []
}