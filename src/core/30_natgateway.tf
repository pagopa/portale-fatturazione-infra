
module "nat_gateway" {
  source = "./.terraform/modules/__v3__/nat_gateway/"

  name                = "${local.project}-natgw"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name

  zones = [1]

  public_ips_count = 1

  tags = var.tags
}
