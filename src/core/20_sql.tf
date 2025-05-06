#tfsec:ignore:azure-database-enable-audit
resource "azurerm_mssql_server" "this" {
  name                = format("%s-%s", local.project, "sqls")
  resource_group_name = azurerm_resource_group.analytics.name
  location            = azurerm_resource_group.analytics.location
  version             = var.sql_version
  # admin auth
  azuread_administrator {
    # this SHOULD be true, but cannot be done right away.
    # there are some clients that need a brutal SQL Server authentication, like PowerBI.
    azuread_authentication_only = false
    login_username              = data.azuread_group.adgroup_admins.display_name
    object_id                   = data.azuread_group.adgroup_admins.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
  }
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mssql_database" "this" {
  # the weird UAT name is due to historical reasons
  name                 = format("%s-%s%s", local.project, "db", var.env_short == "u" ? "-20240128" : "")
  server_id            = azurerm_mssql_server.this.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = var.sql_database_max_size_gb
  sku_name             = var.sql_database_sku_name
  read_scale           = false
  zone_redundant       = false
  storage_account_type = "Zone"
  tags                 = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all # TODO: this is TEMPORARY, we are experimenting in UAT
  }
}

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
