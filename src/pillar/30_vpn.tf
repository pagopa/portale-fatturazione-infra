
# vpn gateway
module "vpn" {
  source = "./.terraform/modules/__v4__/vpn_gateway/"

  count = var.vpn_enabled ? 1 : 0

  name                  = "${local.project}-vpn"
  resource_group_name   = azurerm_resource_group.networking.name
  sku                   = var.vpn_gw_sku
  pip_sku               = "Standard"
  pip_allocation_method = "Static"
  location              = azurerm_resource_group.networking.location
  subnet_id             = azurerm_subnet.vpn[0].id
  vpn_client_configuration = [
    {
      address_space         = ["172.16.1.0/24"],
      vpn_client_protocols  = ["OpenVPN"],
      aad_audience          = data.azuread_application.vpn[0].application_id
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

# dns forwarder
module "dns_fwd" {
  source = "./.terraform/modules/__v4__/dns_forwarder_deprecated/"

  count = var.vpn_enabled ? 1 : 0

  name                = format("%s-%s", local.project, "dns-fwd")
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.dns_fwd[0].id

  tags = var.tags
}
