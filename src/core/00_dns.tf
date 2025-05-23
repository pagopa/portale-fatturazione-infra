#
# general
#
# env-specific dns zone
resource "azurerm_dns_zone" "portalefatturazione" {
  count               = (var.dns_zone_portalefatturazione_prefix == null || var.dns_external_domain == null) ? 0 : 1
  name                = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

# prod-only record to "previous" env dns delegation for dev
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

# prod-only record to "previous" env dns delegation for uat
resource "azurerm_dns_ns_record" "uat_portalefatturazione_pagopa_it_ns" {
  count               = var.env_short == "p" ? 1 : 0
  name                = "uat"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records = [
    "ns1-05.azure-dns.com.",
    "ns2-05.azure-dns.net.",
    "ns3-05.azure-dns.org.",
    "ns4-05.azure-dns.info.",
  ]
  ttl  = var.dns_default_ttl_sec
  tags = var.tags
}

#
# agw
#
# to app-fe
resource "azurerm_dns_a_record" "agw_apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# to app-api
resource "azurerm_dns_a_record" "agw_api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# provide a custom hostname for the public storage account by passing through the agw
resource "azurerm_dns_a_record" "agw_storage" {
  name                = "storage"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

# to integration-func
resource "azurerm_dns_a_record" "agw_integration" {
  name                = "integration"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
  resource_group_name = azurerm_resource_group.networking.name
  records             = [azurerm_public_ip.agw.ip_address]
  ttl                 = var.dns_default_ttl_sec
  tags                = var.tags
}

#
# dns private zone name list:
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
#

# app service
resource "azurerm_private_dns_zone" "privatelink_azurewebsites_net" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azurewebsites_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azurewebsites_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azurewebsites_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azurewebsites_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

# azure sql
resource "azurerm_private_dns_zone" "privatelink_database_windows_net" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_database_windows_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_database_windows_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_database_windows_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_database_windows_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

# storage
resource "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_dfs_core_windows_net" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_queue_core_windows_net" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_table_core_windows_net" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_core_windows_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dfs_core_windows_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dfs_core_windows_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_core_windows_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dfs_core_windows_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dfs_core_windows_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_queue_core_windows_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_queue_core_windows_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_table_core_windows_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_table_core_windows_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_queue_core_windows_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_queue_core_windows_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_table_core_windows_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_table_core_windows_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

# synapse
resource "azurerm_private_dns_zone" "privatelink_sql_azuresynapse_net" {
  name                = "privatelink.sql.azuresynapse.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_sql_azuresynapse_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_sql_azuresynapse_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_sql_azuresynapse_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_sql_azuresynapse_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_dev_azuresynapse_net" {
  name                = "privatelink.dev.azuresynapse.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dev_azuresynapse_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dev_azuresynapse_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dev_azuresynapse_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dev_azuresynapse_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_azuresynapse_net" {
  name                = "privatelink.azuresynapse.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azuresynapse_net_vnet" {
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azuresynapse_net.name
  virtual_network_id    = module.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azuresynapse_net_secondary_vnet" {
  name                  = module.secondary_vnet.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azuresynapse_net.name
  virtual_network_id    = module.secondary_vnet.id
  tags                  = var.tags
}

#
# other
#

# caa record
resource "azurerm_dns_caa_record" "this" {
  name                = "@"
  zone_name           = azurerm_dns_zone.portalefatturazione[0].name
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
