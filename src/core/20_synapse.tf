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
  # admin auth
  # azuread_authentication_only = true
  # FIXME https://github.com/hashicorp/terraform-provider-azurerm/pull/23659
  sql_administrator_login = "sqladminuser"
  aad_admin {
    login     = data.azuread_group.adgroup_admin.display_name
    object_id = data.azuread_group.adgroup_admin.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
  azure_devops_repo {
    account_name    = "pagopaspa"
    branch_name     = "main"
    repository_name = "portale-fatturazione-synapse"
    project_name    = "fatturazione-projects"
    root_folder     = "/"
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

resource "azurerm_synapse_integration_runtime_azure" "this" {
  name                 = format("%s-%s", local.project, "synw-integration-runtime")
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  location             = var.secondary_location
}

resource "azurerm_synapse_firewall_rule" "this" {
  name                 = "allowAll"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = "0.0.0.0"         # FIXME
  end_ip_address       = "255.255.255.255" # FIXME
}

resource "azurerm_synapse_linked_service" "this" {
  name                 = format("%s-%s", local.project, "synw-linked-service-sql")
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
  depends_on = [
    azurerm_synapse_firewall_rule.this
  ]
}

# private endpoint
resource "azurerm_private_endpoint" "web_azuresynapse" {
  name                = format("%s-endpoint", azurerm_synapse_workspace.this.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_synapse_workspace.this.name)
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["web"]
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
    subresource_names              = ["dev"]
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
    subresource_names              = ["sql"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_sql_azuresynapse_net.id]
  }
  tags = var.tags
}