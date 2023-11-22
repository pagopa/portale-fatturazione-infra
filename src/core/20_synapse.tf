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