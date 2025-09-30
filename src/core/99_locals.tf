locals {
  project          = "${var.prefix}-${var.env_short}"
  fqdn_api         = join(".", [var.dns_api_prefix, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_fe          = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_storage     = join(".", [azurerm_dns_a_record.agw_storage.name, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_integration = join(".", [azurerm_dns_a_record.agw_integration.name, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  # certificate names by convention over configuration
  cert_name_api         = replace(local.fqdn_api, ".", "-")
  cert_name_apex        = replace(local.fqdn_fe, ".", "-")
  cert_name_storage     = replace(local.fqdn_storage, ".", "-")
  cert_name_integration = replace(local.fqdn_integration, ".", "-")
}
