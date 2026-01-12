locals {
  project          = "${var.prefix}-${var.env_short}"
  fqdn_api         = join(".", [azurerm_dns_a_record.agw_api.name, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_fe          = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_storage     = join(".", [azurerm_dns_a_record.agw_storage.name, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  fqdn_integration = join(".", [azurerm_dns_a_record.agw_integration.name, var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  # certificate names by convention over configuration
  cert_name_api         = replace(local.fqdn_api, ".", "-")
  cert_name_apex        = replace(local.fqdn_fe, ".", "-")
  cert_name_storage     = replace(local.fqdn_storage, ".", "-")
  cert_name_integration = replace(local.fqdn_integration, ".", "-")

  # private dns zones for private link
  # https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
  #
  privatelink_dns_zone_names = {
    appservice    = "privatelink.azurewebsites.net"
    sqldatabase   = "privatelink.database.windows.net"
    storage_blob  = "privatelink.blob.core.windows.net"
    storage_dfs   = "privatelink.dfs.core.windows.net"
    storage_queue = "privatelink.queue.core.windows.net"
    storage_table = "privatelink.table.core.windows.net"
    synapse       = "privatelink.azuresynapse.net"
    synapse_dev   = "privatelink.dev.azuresynapse.net"
    synapse_sql   = "privatelink.sql.azuresynapse.net"
    # TODO keyvault = "privatelink.vaultcore.azure.net"
  }

  privatelink_dns_zone_ids = {
    for label, zone in local.privatelink_dns_zone_names : label => format(
      "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s",
      data.azurerm_subscription.current.subscription_id,
      data.azurerm_resource_group.networking.name,
      zone,
    )
  }
}
