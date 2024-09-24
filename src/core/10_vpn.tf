module "vpn_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = "GatewaySubnet" # vpn_gateway quirk, this is expected
  address_prefixes                          = var.cidr_vpn_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = []
}

data "azuread_application" "vpn_app" {
  display_name = format("%s-%s", local.project, "app-vpn") # hardcoded, created in eng-azure-authorization
}

module "vpn" {
  source              = "./.terraform/modules/__v3__/vpn_gateway/"
  name                = format("%s-%s", local.project, "vpn")
  resource_group_name = azurerm_resource_group.networking.name
  sku                 = "VpnGw1"
  # TODO the following is because we can't anymore configure a VPN gateway with Basic sku pip.
  #  Migrate the production config too!
  pip_sku               = var.env_short == "p" ? "Basic" : "Standard"
  pip_allocation_method = var.env_short == "p" ? "Dynamic" : "Static"
  location              = azurerm_resource_group.networking.location
  subnet_id             = module.vpn_snet.id
  vpn_client_configuration = [
    {
      address_space         = ["172.16.1.0/24"],
      vpn_client_protocols  = ["OpenVPN"],
      aad_audience          = data.azuread_application.vpn_app.application_id
      aad_issuer            = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/"
      aad_tenant            = "https://login.microsoftonline.com/${data.azurerm_subscription.current.tenant_id}"
      radius_server_address = null
      radius_server_secret  = null
      revoked_certificate   = []
      root_certificate      = []
    }
  ]
  tags = var.tags
}

## dns forwarder
module "dns_fwd_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = format("%s-%s-snet", local.project, "dns-fwd")
  address_prefixes                          = var.cidr_dns_fwd_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  # use subnet delegation
  # https://learn.microsoft.com/en-us/azure/container-instances/container-instances-custom-dns
  delegation = {
    name = "delegation"
    service_delegation = {
      name    = "Microsoft.ContainerInstance/containerGroups" # delegate to this service
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "dns_fwd" {
  source              = "./.terraform/modules/__v3__/dns_forwarder/"
  name                = format("%s-%s", local.project, "dns-fwd")
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = module.dns_fwd_snet.id
  tags                = var.tags
}
