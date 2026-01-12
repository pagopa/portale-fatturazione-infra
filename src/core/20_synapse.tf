resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "default"
  storage_account_id = module.dls_storage.id
}

resource "azurerm_synapse_workspace" "this" {
  name                                 = format("%s-%s", local.project, "synw")
  resource_group_name                  = data.azurerm_resource_group.analytics.name
  location                             = var.secondary_location # not available in italynorth
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id
  managed_virtual_network_enabled      = true
  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = false
  azuread_authentication_only          = true
  sql_administrator_login              = "sqladminuser"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      azure_devops_repo, # manual configuration
    ]
  }
}

resource "azurerm_synapse_workspace_aad_admin" "this" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  login                = data.azuread_group.adgroup_admins.display_name
  object_id            = data.azuread_group.adgroup_admins.object_id
  tenant_id            = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_synapse_spark_pool" "sparkcls01" {
  name                 = "sparkcls01" # name must be sparkcls01, notebooks use this reference
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

resource "azurerm_role_assignment" "synw_sap_storage_blob_data_contributor" {
  scope                = module.sap_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "synw_public_storage_blob_data_contributor" {
  scope                = module.public_storage.id
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
  name                 = format("%s_%s", var.prefix, "sql")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureSqlDatabase"
  type_properties_json = <<JSON
  {
    "connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${azurerm_mssql_server.this.fully_qualified_domain_name};Initial Catalog=${azurerm_mssql_database.this.name}"
  }
  JSON
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
}

resource "azurerm_synapse_linked_service" "sap_storage" {
  name                 = format("%s_%s", var.prefix, "sap")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
  {
    "serviceEndpoint": "https://${module.sap_storage.name}.blob.core.windows.net/",
    "accountKind": "StorageV2"
  }
  JSON
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
}

resource "azurerm_synapse_linked_service" "sa_storage" {
  name                 = format("%s_%s", var.prefix, "sa")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
  {
    "serviceEndpoint": "https://${module.sa_storage.name}.blob.core.windows.net/",
    "accountKind": "StorageV2"
  }
  JSON
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
}

resource "azurerm_synapse_linked_service" "dls_storage" {
  name                 = format("%s_%s", var.prefix, "adls") # different agreed naming convention
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobFS"
  type_properties_json = <<JSON
  {
    "url": "https://${module.dls_storage.name}.dfs.core.windows.net/"
  }
  JSON
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
}

resource "azurerm_synapse_linked_service" "delta" {
  name                 = format("%s_%s", var.prefix, "delta") # different agreed naming convention
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
    name = "AutoResolveIntegrationRuntime"
  }
}

# private endpoints
resource "azurerm_private_endpoint" "web_azuresynapse" {
  name                = format("%s-web-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = data.azurerm_resource_group.analytics.name
  subnet_id           = data.azurerm_subnet.private_endpoint_secondary.id
  private_service_connection {
    name                           = format("%s-web-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_private_link_hub.this.id
    is_manual_connection           = false
    subresource_names              = ["Web"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.synapse]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "dev_azuresynapse" {
  name                = format("%s-dev-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = data.azurerm_resource_group.analytics.name
  subnet_id           = data.azurerm_subnet.private_endpoint_secondary.id
  private_service_connection {
    name                           = format("%s-dev-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["Dev"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.synapse_dev]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_azuresynapse" {
  name                = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = data.azurerm_resource_group.analytics.name
  subnet_id           = data.azurerm_subnet.private_endpoint_secondary.id
  private_service_connection {
    name                           = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.synapse_sql]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_ondemand_azuresynapse" {
  name                = format("%s-sql-ondemand-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = data.azurerm_resource_group.analytics.name
  subnet_id           = data.azurerm_subnet.private_endpoint_secondary.id
  private_service_connection {
    name                           = format("%s-sql-ondemand-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["SqlOnDemand"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.synapse_sql]
  }
  tags = var.tags
}

# private link hub
resource "azurerm_synapse_private_link_hub" "this" {
  name                = replace(format("%s-link-hub", azurerm_synapse_workspace.this.name), "-", "")
  resource_group_name = data.azurerm_resource_group.analytics.name
  location            = var.secondary_location
}

# synapse roles
resource "azurerm_synapse_role_assignment" "admins" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Administrator"
  principal_id         = data.azuread_group.adgroup_admins.object_id
  principal_type       = "Group"
}

resource "azurerm_synapse_role_assignment" "developers" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Contributor"
  principal_id         = data.azuread_group.adgroup_developers.object_id
  principal_type       = "Group"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "sql" {
  name                 = format("%s-sql-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = azurerm_mssql_server.this.id
  subresource_name     = "sqlServer"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "sa_storage" {
  name                 = format("%s-sa-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.sa_storage.id
  subresource_name     = "blob"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "sap_storage" {
  name                 = format("%s-sap-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.sap_storage.id
  subresource_name     = "blob"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "dls_storage_blob" {
  name                 = format("%s-dls-storage-blob-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.dls_storage.id
  subresource_name     = "dfs"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "dls_storage_dfs" {
  name                 = format("%s-dls-storage-dfs-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.dls_storage.id
  subresource_name     = "blob"
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "public_storage" {
  name                 = format("%s-public-storage-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = module.public_storage.id
  subresource_name     = "blob"
}

# private endpoint for a CRM data lake EXTERNAL to this subscription,
# we reference it directly by its id
resource "azurerm_synapse_managed_private_endpoint" "crm_storage_dfs" {
  count = var.crm_storage_id != null ? 1 : 0

  name                 = format("%s-crm-storage-dfs-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = var.crm_storage_id
  subresource_name     = "dfs"
}

resource "azurerm_synapse_managed_private_endpoint" "crm_storage_blob" {
  count = var.crm_storage_id != null ? 1 : 0

  name                 = format("%s-crm-storage-blob-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = var.crm_storage_id
  subresource_name     = "blob"
}

resource "azurerm_synapse_managed_private_endpoint" "kv" {
  name                 = format("%s-kv-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = data.azurerm_key_vault.app.id
  subresource_name     = "vault"
}

# access to api func

data "azurerm_function_app_host_keys" "api_func" {
  name                = azurerm_linux_function_app.api.name
  resource_group_name = azurerm_linux_function_app.api.resource_group_name
}

resource "azurerm_synapse_linked_service" "api_func" {
  name                 = "${var.prefix}_api_func"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureFunction"
  type_properties_json = <<JSON
  {
    "functionAppUrl": "https://${azurerm_linux_function_app.api.default_hostname}",
    "functionKey":
      {
        "type": "SecureString",
        "value": "${data.azurerm_function_app_host_keys.api_func.primary_key}"
      }
  }
  JSON
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
}

# managed_private_endpoint must be manual approved on target resource
resource "azurerm_synapse_managed_private_endpoint" "api_func" {
  name                 = format("%s-api-func-endpoint", azurerm_synapse_workspace.this.name)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = azurerm_linux_function_app.api.id
  subresource_name     = "sites"
}

resource "azurerm_synapse_role_assignment" "api_synapse_user" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse User"
  principal_id         = azurerm_linux_web_app.app_api.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_synapse_role_assignment" "api_synapse_credential_user" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Credential User"
  principal_id         = azurerm_linux_web_app.app_api.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_key_vault_access_policy" "synw_app" {
  key_vault_id = data.azurerm_key_vault.app.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_synapse_workspace.this.identity[0].principal_id

  key_permissions         = []
  secret_permissions      = ["Get", "List", ]
  storage_permissions     = []
  certificate_permissions = []
}
