#
# Legacy storage account created historically in DEV environment. it
# should be fatdsap but it's fatdsaptest and it's completely drifted
# from what it should be in any possible way. we just keep it to avoid
# breaking an integration.
#
# NOTE: this whole file is ONLY for DEV.
#

# __generated__ by Terraform
resource "azurerm_storage_account" "sap_legacy_dev" {
  count = var.env_short == "d" ? 1 : 0

  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  allowed_copy_scope                = null
  cross_tenant_replication_enabled  = false
  default_to_oauth_authentication   = false
  dns_endpoint_type                 = "Standard"
  edge_zone                         = null
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = false
  is_hns_enabled                    = false
  large_file_share_enabled          = false
  local_user_enabled                = true
  location                          = "westeurope"
  min_tls_version                   = "TLS1_2"
  name                              = "fatdsaptest"
  nfsv3_enabled                     = false
  provisioned_billing_model_version = null
  public_network_access_enabled     = true
  queue_encryption_key_type         = "Account"
  resource_group_name               = "terraform-state-rg"
  sftp_enabled                      = false
  shared_access_key_enabled         = true
  table_encryption_key_type         = "Account"
  network_rules {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = var.storage_sap_rule_ips
    virtual_network_subnet_ids = []
  }
  share_properties {
    retention_policy {
      days = 7
    }
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access,
      blob_properties,
    ]
  }
}

resource "azurerm_private_endpoint" "sap_storage_blob_legacy_dev" {
  count = var.env_short == "d" ? 1 : 0

  name                = format("%s-blob-endpoint", azurerm_storage_account.sap_legacy_dev[0].name)
  location            = var.secondary_location
  resource_group_name = data.azurerm_resource_group.analytics.name
  subnet_id           = data.azurerm_subnet.private_endpoint_secondary.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", azurerm_storage_account.sap_legacy_dev[0].name)
    private_connection_resource_id = azurerm_storage_account.sap_legacy_dev[0].id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.storage_blob]
  }

  tags = var.tags
}

# we will use this in the rest of the code
locals {
  sap_storage_id        = var.env_short == "d" ? azurerm_storage_account.sap_legacy_dev[0].id : module.sap_storage.id
  sap_storage_name      = var.env_short == "d" ? azurerm_storage_account.sap_legacy_dev[0].name : module.sap_storage.name
  sap_storage_blob_host = var.env_short == "d" ? azurerm_storage_account.sap_legacy_dev[0].primary_blob_host : module.sap_storage.primary_blob_host
}
