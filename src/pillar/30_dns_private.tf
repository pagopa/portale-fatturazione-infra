#
# dns private zone name list:
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
#

locals {
  private_dns_zones = [
    # app service
    "privatelink.azurewebsites.net",
    # sql database
    "privatelink.database.windows.net",
    # TODO key vault
    # TODO "privatelink.vaultcore.azure.net",
    # storage
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    # synapse
    "privatelink.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.sql.azuresynapse.net",
  ]
}


# private dns zones
resource "azurerm_private_dns_zone" "privatelink" {
  for_each = toset(local.private_dns_zones)

  name                = each.key
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

# link to primary
resource "azurerm_private_dns_zone_virtual_network_link" "privatelink" {
  for_each = toset(local.private_dns_zones)

  name                  = azurerm_virtual_network.primary.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = each.key
  virtual_network_id    = azurerm_virtual_network.primary.id
  tags                  = var.tags

  depends_on = [azurerm_private_dns_zone.privatelink]
}

# link to secondary
resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_secondary" {
  for_each = toset(local.private_dns_zones)

  name                  = azurerm_virtual_network.secondary.name
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = each.key
  virtual_network_id    = azurerm_virtual_network.secondary.id
  tags                  = var.tags

  depends_on = [azurerm_private_dns_zone.privatelink]
}
