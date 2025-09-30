#
# Public DNS
#

# env-specific dns zone
resource "azurerm_dns_zone" "portalefatturazione" {
  name                = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  resource_group_name = azurerm_resource_group.networking.name

  tags = var.tags
}

# prod-only record to "previous" env dns delegation for dev
resource "azurerm_dns_ns_record" "dev_portalefatturazione_pagopa_it_ns" {
  count               = var.env_short == "p" ? 1 : 0
  name                = "dev"
  zone_name           = azurerm_dns_zone.portalefatturazione.name
  resource_group_name = azurerm_resource_group.networking.name
  records = [
    "ns1-33.azure-dns.com.",
    "ns2-33.azure-dns.net.",
    "ns3-33.azure-dns.org.",
    "ns4-33.azure-dns.info.",
  ]
  ttl = var.dns_default_ttl_sec

  tags = var.tags
}

# prod-only record to "previous" env dns delegation for uat
resource "azurerm_dns_ns_record" "uat_portalefatturazione_pagopa_it_ns" {
  count               = var.env_short == "p" ? 1 : 0
  name                = "uat"
  zone_name           = azurerm_dns_zone.portalefatturazione.name
  resource_group_name = azurerm_resource_group.networking.name
  records = [
    "ns1-05.azure-dns.com.",
    "ns2-05.azure-dns.net.",
    "ns3-05.azure-dns.org.",
    "ns4-05.azure-dns.info.",
  ]
  ttl = var.dns_default_ttl_sec

  tags = var.tags
}

# caa record
resource "azurerm_dns_caa_record" "portalefatturazione_apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.portalefatturazione.name
  resource_group_name = azurerm_resource_group.networking.name
  ttl                 = var.dns_default_ttl_sec

  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "digicert.com"
  }

  record {
    flags = 0
    tag   = "iodef"
    value = "mailto:security+caa@pagopa.it"
  }

  tags = var.tags
}
