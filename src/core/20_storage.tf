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
  public_network_access_enabled        = true # FIXME
  tags                                 = var.tags
}

# TODO should container names be a variable?

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

#
# sa storage
#

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
  public_network_access_enabled        = true # from datalake, over public network
  tags                                 = var.tags
}

resource "azurerm_storage_container" "sa_pfat" {
  name                  = "pfat"
  storage_account_name  = module.sa_storage.name
  container_access_type = "private"
}
