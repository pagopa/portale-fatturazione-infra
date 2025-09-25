#
# Durable Function App for async long running task.
# This function is used internally.
# NOTE: the name fat-<env>-api-func is for historical reasons
#

module "api_func_storage" {
  source = "./.terraform/modules/__v4__/storage_account/"

  name                                 = replace("${local.project}apifuncsa", "-", "")
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

resource "azurerm_private_endpoint" "api_func_storage_blob" {
  name                = format("%s-blob-endpoint", module.api_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.api_func_storage.name)
    private_connection_resource_id = module.api_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "api_func_storage_queue" {
  name                = format("%s-queue-endpoint", module.api_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-queue-endpoint", module.api_func_storage.name)
    private_connection_resource_id = module.api_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_queue_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "api_func_storage_table" {
  name                = format("%s-table-endpoint", module.api_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-table-endpoint", module.api_func_storage.name)
    private_connection_resource_id = module.api_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_table_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_linux_function_app" "api" {
  name                = "${local.project}-api-func"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  storage_account_name          = module.api_func_storage.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.app.id
  client_certificate_enabled    = false
  https_only                    = true
  functions_extension_version   = "~4"
  public_network_access_enabled = false

  site_config {
    always_on                = true
    use_32_bit_worker        = false
    ftps_state               = "Disabled"
    http2_enabled            = true
    minimum_tls_version      = "1.2"
    scm_minimum_tls_version  = "1.2"
    vnet_route_all_enabled   = true
    application_insights_key = azurerm_application_insights.application_insights.instrumentation_key
    # health_check_path       = "/health" TODO

    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]
      support_credentials = true
    }
  }

  app_settings = {
    APPINSIGHTS_SAMPLING_PERCENTAGE        = 5
    WEBSITE_DNS_SERVER                     = "168.63.129.16" # standard azure dns
    WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED = "1"
    WEBSITE_RUN_FROM_PACKAGE               = "1"

    CONNECTION_STRING = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ConnectionString)"
    SMTP              = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=Smtp)"
    SMTP_PORT         = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpPort)"
    SMTP_AUTH         = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpAuth)"
    SMTP_PASSWORD     = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpPassword)"
    ACCESSTOKEN       = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ACCESSTOKEN)"
    CLIENTID          = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=CLIENTID)"
    CLIENTSECRET      = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=CLIENTSECRET)"
    FROM              = "no-reply_fatturazione@pagopa.it"
    FROMNAME          = "pagoPA"
    REFRESHTOKEN      = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=REFRESHTOKEN)"

    StorageRELAccountName       = module.public_storage.name
    StorageRELAccountKey        = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=${azurerm_key_vault_secret.public_storage_key.name})"
    StorageRELBlobContainerName = "relrighe"

    StorageNotificheAccountKey        = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=${azurerm_key_vault_secret.public_storage_key.name})"
    StorageNotificheAccountName       = module.public_storage.name
    StorageNotificheBlobContainerName = "notifiche"

    ModuloCommessaSEND            = "${var.send_api_url}/pn-portfat-in/file-ready-event",
    ModuloCommessaSENDAccountKey  = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SENDAccountKey)",
    ModuloCommessaSENDFileVersion = "1.0.0"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_role_assignment" "api_func_storage_blob_contributor" {
  scope                = module.api_func_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.api.identity[0].principal_id
}

resource "azurerm_role_assignment" "api_func_storage_queue_contributor" {
  scope                = module.api_func_storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_linux_function_app.api.identity[0].principal_id
}

resource "azurerm_role_assignment" "api_func_storage_table_contributor" {
  scope                = module.api_func_storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_function_app.api.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "api_func_get_secrets" {
  key_vault_id       = module.key_vault_app.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app.api.identity[0].principal_id
  secret_permissions = ["Get"]
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "api_func" {
  app_service_id = azurerm_linux_function_app.api.id
  subnet_id      = module.app_snet.id
}

# private endpoint
resource "azurerm_private_endpoint" "api_func" {
  name                = format("%s-endpoint", azurerm_linux_function_app.api.name)
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_function_app.api.name)
    private_connection_resource_id = azurerm_linux_function_app.api.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}


#
# Durable Function App for public integration API.
# This function is used publicly, exposed via the app gw.
#

module "integration_func_storage" {
  source = "./.terraform/modules/__v4__/storage_account/"

  name                                 = replace("${local.project}integrationfuncsa", "-", "")
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

resource "azurerm_private_endpoint" "integration_func_storage_blob" {
  name                = format("%s-blob-endpoint", module.integration_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-blob-endpoint", module.integration_func_storage.name)
    private_connection_resource_id = module.integration_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "integration_func_storage_queue" {
  name                = format("%s-queue-endpoint", module.integration_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-queue-endpoint", module.integration_func_storage.name)
    private_connection_resource_id = module.integration_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_queue_core_windows_net.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "integration_func_storage_table" {
  name                = format("%s-table-endpoint", module.integration_func_storage.name)
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.analytics.name
  subnet_id           = module.private_endpoint_secondary_snet.id

  private_service_connection {
    name                           = format("%s-table-endpoint", module.integration_func_storage.name)
    private_connection_resource_id = module.integration_func_storage.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_table_core_windows_net.id]
  }

  tags = var.tags
}

locals {
  integration_func = {
    app_settings = {
      APPINSIGHTS_SAMPLING_PERCENTAGE        = 5
      WEBSITE_DNS_SERVER                     = "168.63.129.16" # standard azure dns
      WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED = "1"
      WEBSITE_RUN_FROM_PACKAGE               = "1"

      CONNECTION_STRING                  = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ConnectionString)"
      AES_KEY                            = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=EncryptionAesKey)"
      STORAGE_ACCOUNT_KEY                = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=PublicStorageKey)"
      STORAGE_ACCOUNT_NAME               = module.public_storage.name
      STORAGE_NOTIFICHE                  = "notifiche"
      STORAGE_REL                        = "relrighe"
      STORAGE_REL_DOWNLOAD               = "reldownload"
      STORAGE_CONTESTAZIONI              = "contestazioni"
      STORAGE_CUSTOM_HOSTNAME            = "https://${local.fqdn_storage}"
      StorageDocumenti__ConnectionString = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=RelStorageConnectionString)"
      StorageDocumenti__DocumentiFolder  = "documenti"

      OpenApi__DocDescription = "API documentation Portale Fatturazione."
      OpenApi__DocTitle       = "Portale Fatturazione API"
      OpenApi__DocVersion     = "v1"
      OpenApi__HostNames      = "https://${local.fqdn_integration}/api"

      StorageContestazioni__AccountName       = module.public_storage.name
      StorageContestazioni__AccountKey        = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=PublicStorageKey)"
      StorageContestazioni__BlobContainerName = "contestazioni",
      StorageContestazioni__CustomDns         = "https://${local.fqdn_storage}"

      WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"

      // TODO temporary
      DOCKER_ENABLE_CI = var.env_short != "p" ? "true" : "false"
    }
  }
}
resource "azurerm_linux_function_app" "integration" {
  name                = "${local.project}-integration-func"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  storage_account_name          = module.integration_func_storage.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.app.id
  client_certificate_enabled    = false
  https_only                    = true
  functions_extension_version   = "~4"
  public_network_access_enabled = false
  enabled                       = var.function_app_integration_enabled

  site_config {
    always_on                = true
    use_32_bit_worker        = false
    ftps_state               = "Disabled"
    http2_enabled            = true
    minimum_tls_version      = "1.2"
    scm_minimum_tls_version  = "1.2"
    vnet_route_all_enabled   = true
    application_insights_key = azurerm_application_insights.application_insights.instrumentation_key
    # health_check_path       = "/health" TODO

    application_stack {
      docker {
        image_name   = "pagopa/portale-fatturazione-integration"
        image_tag    = "latest" // ignored, will be mangaed from ci/cd pipeline
        registry_url = "https://ghcr.io"
      }
    }
    cors {
      allowed_origins = [
        "https://portal.azure.com",
        "https://${local.fqdn_integration}",
      ]
      support_credentials = true
    }
  }

  app_settings = merge(
    local.integration_func.app_settings, {
      TaskHubName = "TaskHub"
  })

  sticky_settings {
    app_setting_names = [
      "TaskHubName",
      "OpenApi__HostNames",
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker[0].image_tag,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_role_assignment" "integration_func_storage_blob_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.integration.identity[0].principal_id
}

resource "azurerm_role_assignment" "integration_func_storage_queue_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_linux_function_app.integration.identity[0].principal_id
}

resource "azurerm_role_assignment" "integration_func_storage_table_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_function_app.integration.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "integration_func_get_secrets" {
  key_vault_id       = module.key_vault_app.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app.integration.identity[0].principal_id
  secret_permissions = ["Get"]
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "integration_func" {
  app_service_id = azurerm_linux_function_app.integration.id
  subnet_id      = module.app_snet.id
}

# private endpoint
resource "azurerm_private_endpoint" "integration_func" {
  name                = format("%s-endpoint", azurerm_linux_function_app.integration.name)
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_function_app.integration.name)
    private_connection_resource_id = azurerm_linux_function_app.integration.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}

## SLOT for integration func
resource "azurerm_linux_function_app_slot" "integration_staging" {
  name            = "staging"
  function_app_id = azurerm_linux_function_app.integration.id

  storage_account_name          = module.integration_func_storage.name
  storage_uses_managed_identity = true
  client_certificate_enabled    = false
  https_only                    = true
  public_network_access_enabled = false
  enabled                       = var.function_app_integration_enabled

  site_config {
    always_on                = true
    use_32_bit_worker        = false
    ftps_state               = "Disabled"
    http2_enabled            = true
    minimum_tls_version      = "1.2"
    scm_minimum_tls_version  = "1.2"
    vnet_route_all_enabled   = true
    application_insights_key = azurerm_application_insights.application_insights.instrumentation_key
    # health_check_path       = "/health" TODO

    application_stack {
      docker {
        image_name   = "pagopa/portale-fatturazione-integration"
        image_tag    = "latest" // ignored, will be mangaed from ci/cd pipeline
        registry_url = "https://ghcr.io"
      }
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]
      support_credentials = true
    }
  }

  app_settings = merge(
    local.integration_func.app_settings, {
      OpenApi__HostNames = "https://${local.project}-integration-func-staging.azurewebsites.net/api"
      TaskHubName        = "TaskHubStaging"
  })

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker[0].image_tag,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_role_assignment" "integration_staging_func_storage_blob_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app_slot.integration_staging.identity[0].principal_id
}

resource "azurerm_role_assignment" "integration_staging_func_storage_queue_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_linux_function_app_slot.integration_staging.identity[0].principal_id
}

resource "azurerm_role_assignment" "integration_staging_func_storage_table_contributor" {
  scope                = module.integration_func_storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_function_app_slot.integration_staging.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "integration_staging_func_get_secrets" {
  key_vault_id       = module.key_vault_app.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app_slot.integration_staging.identity[0].principal_id
  secret_permissions = ["Get"]
}

# vnet integration
resource "azurerm_app_service_slot_virtual_network_swift_connection" "integration_func_staging" {
  slot_name      = azurerm_linux_function_app_slot.integration_staging.name
  app_service_id = azurerm_linux_function_app.integration.id
  subnet_id      = module.app_snet.id

  depends_on = [azurerm_linux_function_app_slot.integration_staging]
}

# private endpoint
resource "azurerm_private_endpoint" "integration_staging_func" {
  name                = "${azurerm_linux_function_app.integration.name}-${azurerm_linux_function_app_slot.integration_staging.name}-endpoint"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = "${azurerm_linux_function_app.integration.name}-${azurerm_linux_function_app_slot.integration_staging.name}-endpoint"
    private_connection_resource_id = azurerm_linux_function_app.integration.id
    is_manual_connection           = false
    # https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint#conceptual-overview
    subresource_names = ["sites-${azurerm_linux_function_app_slot.integration_staging.name}"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}
