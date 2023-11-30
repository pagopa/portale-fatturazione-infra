resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "default"
  storage_account_id = module.dls_storage.id
}

resource "azurerm_synapse_workspace" "this" {
  name                                 = format("%s-%s", local.project, "synw")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location # not available in italynorth
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id
  managed_virtual_network_enabled      = true
  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = true
  # admin auth
  # azuread_authentication_only = true
  # FIXME https://github.com/hashicorp/terraform-provider-azurerm/pull/23659
  sql_administrator_login = "sqladminuser"
  aad_admin {
    login     = data.azuread_group.adgroup_admins.display_name
    object_id = data.azuread_group.adgroup_admins.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_synapse_spark_pool" "sparkcls01" {
  name                 = "sparkcls01"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small" # FIXME
  spark_version        = var.syn_spark_version
  cache_size           = 50
  auto_scale {
    max_node_count = 6 # FIXME
    min_node_count = 3 # FIXME
  }
  auto_pause {
    delay_in_minutes = 15
  }
  tags = var.tags
}

# role assignments
resource "azurerm_role_assignment" "synw_sa_storage_blob_data_contributor" {
  scope                = module.sa_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "synw_dls_storage_blob_data_contributor" {
  scope                = module.dls_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
}

# integration runtime
resource "azurerm_synapse_integration_runtime_azure" "this" {
  name                 = format("%s-%s", local.project, "synw-integration-runtime")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  location             = var.secondary_location
}

# linked service
# FIXME azure sql public_network_access_enabled = false -> azurerm_synapse_linked_service.this depends_on pvt endpoints?
resource "azurerm_synapse_linked_service" "sql" {
  name                 = format("%s-%s", local.prefix, "sql")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureSqlDatabase"
  type_properties_json = <<JSON
  {
    "connectionString": "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.this.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication='Active Directory Default';"
  }
  JSON
  integration_runtime {
    name = azurerm_synapse_integration_runtime_azure.this.name
  }
}

resource "azurerm_synapse_linked_service" "sap_storage" {
  name                 = format("%s-%s", local.prefix, "sap")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
  {
    "connectionString": "${module.sap_storage.primary_blob_connection_string}"
  }
  JSON
  integration_runtime {
    name = azurerm_synapse_integration_runtime_azure.this.name
  }
}

resource "azurerm_synapse_linked_service" "sa_storage" {
  name                 = format("%s-%s", local.prefix, "sa")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
  {
    "connectionString": "${module.sa_storage.primary_blob_connection_string}"
  }
  JSON
  integration_runtime {
    name = azurerm_synapse_integration_runtime_azure.this.name
  }
}

resource "azurerm_synapse_linked_service" "dls_storage" {
  name                 = format("%s-%s", local.prefix, "adls") # different agreed naming convention
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobFS"
  type_properties_json = <<JSON
  {
    "url": "https://${module.dls_storage.name}.dfs.core.windows.net/"
  }
  JSON
  integration_runtime {
    name = azurerm_synapse_integration_runtime_azure.this.name
  }
}

resource "azurerm_synapse_linked_service" "delta" {
  name                 = format("%s-%s", local.prefix, "delta") # different agreed naming convention
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureSqlDW"
  type_properties_json = <<JSON
  {
    "connectionString": "Data Source=tcp:${azurerm_synapse_workspace.this.name}-ondemand.sql.azuresynapse.net,1433;Initial Catalog=@{linkedService().DBName};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  JSON
  parameters = {
    DBName = ""
  }
  integration_runtime {
    name = azurerm_synapse_integration_runtime_azure.this.name
  }
}

# private endpoints
resource "azurerm_private_endpoint" "web_azuresynapse" {
  name                = format("%s-web-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id
  private_service_connection {
    name                           = format("%s-web-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_private_link_hub.this.id
    is_manual_connection           = false
    subresource_names              = ["Web"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azuresynapse_net.id]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "dev_azuresynapse" {
  name                = format("%s-dev-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id
  private_service_connection {
    name                           = format("%s-dev-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["Dev"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_dev_azuresynapse_net.id]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_azuresynapse" {
  name                = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id
  private_service_connection {
    name                           = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_sql_azuresynapse_net.id]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_ondemand_azuresynapse" {
  name                = format("%s-sql-ondemand-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id
  private_service_connection {
    name                           = format("%s-sql-ondemand-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["SqlOnDemand"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_sql_azuresynapse_net.id]
  }
  tags = var.tags
}

# private link hub
resource "azurerm_synapse_private_link_hub" "this" {
  name                = replace(format("%s-link-hub", azurerm_synapse_workspace.this.name), "-", "")
  resource_group_name = azurerm_resource_group.analytics.name
  location            = var.secondary_location
}

# synapse roles
resource "azurerm_synapse_role_assignment" "admins" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Administrator"
  principal_id         = data.azuread_group.adgroup_admins.object_id
}

resource "azurerm_synapse_role_assignment" "developers" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Contributor"
  principal_id         = data.azuread_group.adgroup_developers.object_id
}

resource "azurerm_synapse_managed_private_endpoint" "sql" {
  name                 = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = azurerm_mssql_server.this.id
  subresource_name     = "sqlServer"
}

resource "azurerm_synapse_managed_private_endpoint" "sa_storage" {
  name                 = format("%s-sa-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.sa_storage.id
  subresource_name     = "blob"
}

resource "azurerm_synapse_managed_private_endpoint" "sap_storage" {
  name                 = format("%s-sap-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.sap_storage.id
  subresource_name     = "blob"
}

resource "azurerm_synapse_managed_private_endpoint" "dls_storage" {
  name                 = format("%s-dls-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.dls_storage.id
  subresource_name     = "dls"
}
