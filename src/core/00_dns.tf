resource "azurerm_dns_zone" "portalefatturazione" {
  count               = (var.dns_zone_portalefatturazione_prefix == null || var.external_domain == null) ? 0 : 1
  name                = join(".", [var.dns_zone_portalefatturazione_prefix, var.external_domain])
  resource_group_name = azurerm_resource_group.networking.name

  tags = var.tags
}

# Prod ONLY record to DEV public DNS delegation
resource "azurerm_dns_ns_record" "dev_portalefatturazione_pagopa_it_ns" {
  count               = var.env_short == "p" ? 1 : 0
  name                = "dev"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records = [
    "ns1-33.azure-dns.com.",
    "ns2-33.azure-dns.net.",
    "ns3-33.azure-dns.org.",
    "ns4-33.azure-dns.info.",
  ]
  ttl  = var.dns_default_ttl_sec
  tags = var.tags
}