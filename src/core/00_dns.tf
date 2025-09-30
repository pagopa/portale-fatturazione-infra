#
# general
#
# env-specific dns zone
data "azurerm_dns_zone" "portalefatturazione" {
  name                = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  resource_group_name = data.azurerm_resource_group.networking.name
}

#
# agw
#
# to app-fe
resource "azurerm_dns_a_record" "agw_apex" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.portalefatturazione.name
  resource_group_name = data.azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# to app-api
resource "azurerm_dns_a_record" "agw_api" {
  name                = "api"
  zone_name           = data.azurerm_dns_zone.portalefatturazione.name
  resource_group_name = data.azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# provide a custom hostname for the public storage account by passing through the agw
resource "azurerm_dns_a_record" "agw_storage" {
  name                = "storage"
  zone_name           = data.azurerm_dns_zone.portalefatturazione.name
  resource_group_name = data.azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# to integration-func
resource "azurerm_dns_a_record" "agw_integration" {
  name                = "integration"
  zone_name           = data.azurerm_dns_zone.portalefatturazione.name
  resource_group_name = data.azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}
