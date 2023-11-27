#tfsec:ignore:azure-database-no-public-access
#tfsec:ignore:azure-database-enable-audit
resource "azurerm_mssql_server" "server_weu" {
  name                = format("%s-%s", local.project, "sqls-weu")
  resource_group_name = azurerm_resource_group.analytics.name
  location            = var.secondary_location
  version             = var.sql_version
  # admin auth
  azuread_administrator {
    azuread_authentication_only = true
    login_username              = data.azuread_group.adgroup_admin.display_name
    object_id                   = data.azuread_group.adgroup_admin.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
  }
  public_network_access_enabled = true # FIXME
  minimum_tls_version           = "1.2"
  tags                          = var.tags
}

resource "azurerm_mssql_database" "db_weu" {
  name      = format("%s-%s", local.project, "db-weu")
  server_id = azurerm_mssql_server.server_weu.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  # max_size_gb          = var.sql_database_max_size_gb
  read_replica_count   = 1 # use only with HS sku
  sku_name             = var.sql_database_sku_name
  geo_backup_enabled   = false
  zone_redundant       = true
  storage_account_type = "Zone"
  tags                 = var.tags
}

/*
resource "azurerm_private_endpoint" "sql" {
  name                = format("%s-endpoint", azurerm_mssql_server.this.name)
  location            = azurerm_resource_group.analytics.location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_mssql_server.this.name)
    private_connection_resource_id = azurerm_mssql_server.this.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_database_windows_net.id]
  }
  tags = var.tags
}
*/