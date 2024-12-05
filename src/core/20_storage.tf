#
# dls storage
#
module "dls_storage" {
  source                               = "./.terraform/modules/__v3__/storage_account/"
  name                                 = replace(format("%s-%s", local.project, "dls"), "-", "")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location
  account_kind                         = "StorageV2"
  account_tier                         = "Standard"
  access_tier                          = "Hot"
  account_replication_type             = "ZRS"
  is_hns_enabled                       = true
  blob_versioning_enabled              = false
  blob_delete_retention_days           = var.storage_delete_retention_days
  blob_container_delete_retention_days = var.storage_delete_retention_days
  allow_nested_items_to_be_public      = false
  public_network_access_enabled        = false
  tags                                 = var.tags
}

resource "azurerm_storage_container" "dls_raw" {
  name                  = "raw"
  storage_account_name  = module.dls_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dls_synapse" {
  name                  = "synapse"
  storage_account_name  = module.dls_storage.name
  container_access_type = "private"
}

#tfsec:ignore:azure-keyvault-content-type-for-secret
#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "dls_storage_connection_string" {
  name         = "DlsStorageConnectionString"
  value        = module.dls_storage.primary_connection_string
  key_vault_id = module.key_vault_app.id
}

#
# sa storage
#
#tfsec:ignore:azure-storage-default-action-deny Reason: DataLake needs to upload blob to this storage, we applied ip restrictions
module "sa_storage" {
  source                               = "./.terraform/modules/__v3__/storage_account/"
  name                                 = replace(format("%s-%s", local.project, "sa"), "-", "")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location
  account_kind                         = "StorageV2"
  account_tier                         = "Standard"
  access_tier                          = "Hot"
  account_replication_type             = "ZRS"
  blob_versioning_enabled              = true
  blob_delete_retention_days           = var.storage_delete_retention_days
  blob_container_delete_retention_days = var.storage_delete_retention_days
  allow_nested_items_to_be_public      = false
  public_network_access_enabled        = true
  network_rules = {
    default_action             = length(var.storage_sa_rule_ips) < 1 ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.storage_sa_rule_ips
    virtual_network_subnet_ids = []
  }
  tags = var.tags
}

resource "azurerm_storage_container" "sa_stage" {
  name                  = "pfstage"
  storage_account_name  = module.sa_storage.name
  container_access_type = "private"
}

#
# private endpoints
#

resource "azurerm_private_endpoint" "dls_storage_blob" {
  name                = format("%s-blob-endpoint", module.dls_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.dls_storage.name)
    private_connection_resource_id = module.dls_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "dls_storage_dfs" {
  name                = format("%s-dfs-endpoint", module.dls_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-dfs-endpoint", module.dls_storage.name)
    private_connection_resource_id = module.dls_storage.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_dfs_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "sa_storage_blob" {
  name                = format("%s-blob-endpoint", module.sa_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.sa_storage.name)
    private_connection_resource_id = module.sa_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}

#
# sap storage
#
#tfsec:ignore:azure-storage-default-action-deny Reason: SAP needs to read blob from this storage, we applied ip restrictions
module "sap_storage" {
  source                               = "./.terraform/modules/__v3__/storage_account/"
  name                                 = replace(format("%s-%s", local.project, "sap"), "-", "")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location
  account_kind                         = "StorageV2"
  account_tier                         = "Standard"
  access_tier                          = "Hot"
  account_replication_type             = "ZRS"
  blob_versioning_enabled              = true
  blob_container_delete_retention_days = var.storage_delete_retention_days
  allow_nested_items_to_be_public      = false
  public_network_access_enabled        = true
  network_rules = {
    default_action             = length(var.storage_sap_rule_ips) < 1 ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.storage_sap_rule_ips
    virtual_network_subnet_ids = []
  }
  tags = var.tags
}

resource "azurerm_storage_container" "sap_sap" {
  name                  = "sap"
  storage_account_name  = module.sap_storage.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "sap_storage_blob" {
  name                = format("%s-blob-endpoint", module.sap_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.sap_storage.name)
    private_connection_resource_id = module.sap_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}



#
# rel storage
#
#no public access, used by fatturazione API-BE
module "rel_storage" {
  source                               = "./.terraform/modules/__v3__/storage_account/"
  name                                 = replace(format("%s-%s", local.project, "rel"), "-", "")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location
  account_kind                         = "StorageV2"
  account_tier                         = "Standard"
  access_tier                          = "Hot"
  account_replication_type             = "ZRS"
  blob_versioning_enabled              = true
  blob_container_delete_retention_days = var.storage_delete_retention_days
  allow_nested_items_to_be_public      = false
  public_network_access_enabled        = false
  tags                                 = var.tags
}

#tfsec:ignore:azure-keyvault-content-type-for-secret
#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "rel_storage_connection_string" {
  name         = "RelStorageConnectionString"
  value        = module.rel_storage.primary_connection_string
  key_vault_id = module.key_vault_app.id
}

resource "azurerm_storage_container" "rel_rel" {
  name                  = "rel"
  storage_account_name  = module.rel_storage.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "rel_storage_blob" {
  name                = format("%s-blob-endpoint", module.rel_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.rel_storage.name)
    private_connection_resource_id = module.rel_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}

# public access storage with SAS token
module "public_storage" {
  source                               = "./.terraform/modules/__v3__/storage_account/"
  name                                 = replace(format("%s-%s", local.project, "public"), "-", "")
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = var.secondary_location
  account_kind                         = "StorageV2"
  account_tier                         = "Standard"
  access_tier                          = "Hot"
  account_replication_type             = "ZRS"
  blob_versioning_enabled              = true
  blob_container_delete_retention_days = var.storage_delete_retention_days
  allow_nested_items_to_be_public      = false
  public_network_access_enabled        = true
  tags                                 = var.tags
}

#tfsec:ignore:azure-keyvault-content-type-for-secret
#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "public_storage_key" {
  name         = "PublicStorageKey"
  value        = module.public_storage.primary_access_key
  key_vault_id = module.key_vault_app.id
}

# the public storage is indeed public, but we need to bind a private endpoint for access from whithin the VNET
resource "azurerm_private_endpoint" "public_storage_blob" {
  name                = format("%s-blob-endpoint", module.public_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.public_storage.name)
    private_connection_resource_id = module.public_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}
