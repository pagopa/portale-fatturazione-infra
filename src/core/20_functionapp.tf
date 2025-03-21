
resource "azurerm_storage_account" "function_send_email" {
  name                     = replace("${local.project}sendemailsa", "-", "")
  location                 = azurerm_resource_group.app.location
  resource_group_name      = azurerm_resource_group.app.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_linux_function_app" "send_email" {
  name                = "${local.project}-send-email"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  storage_account_name          = azurerm_storage_account.function_send_email.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.app.id

  client_certificate_enabled = false
  https_only                 = true

  site_config {
    always_on               = true
    use_32_bit_worker       = false
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
    # health_check_path       = "/health" TODO

    application_stack {
      dotnet_version = "7.0" # FIXME
      # dotnet_version is ignored
      # wait https://github.com/hashicorp/terraform-provider-azurerm/commit/73832251e80c390a139688097ffdad3f2f2022e8
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
    APPINSIGHTS_SAMPLING_PERCENTAGE        = 5               # would have been inherited from module
    WEBSITE_DNS_SERVER                     = "168.63.129.16" # would have been inherited from module
    WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED = "1"
    WEBSITE_RUN_FROM_PACKAGE               = "1"
    APPLICATION_INSIGHTS                   = azurerm_application_insights.application_insights.connection_string

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

  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].dotnet_version,
      # temporary values, ignore for the moment
      app_settings["TO"],
      app_settings["TONAME"],
    ]
  }
}

resource "azurerm_role_assignment" "function_send_email_storage_contributor" {
  scope                = azurerm_storage_account.function_send_email.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.send_email.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "function_send_email_get_secrets" {
  key_vault_id       = module.key_vault_app.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app.send_email.identity[0].principal_id
  secret_permissions = ["Get"]
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "send_email_function" {
  app_service_id = azurerm_linux_function_app.send_email.id
  subnet_id      = module.app_snet.id
}

# private endpoint
resource "azurerm_private_endpoint" "send_email_function" {
  name                = format("%s-endpoint", azurerm_linux_function_app.send_email.name)
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_function_app.send_email.name)
    private_connection_resource_id = azurerm_linux_function_app.send_email.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}

module "func_api" {
  source = "./.terraform/modules/__v4__/function_app/"

  name                                     = "${local.project}-api-func"
  resource_group_name                      = azurerm_resource_group.app.name
  location                                 = azurerm_resource_group.app.location
  always_on                                = true
  enable_healthcheck                       = false
  application_insights_instrumentation_key = azurerm_application_insights.application_insights.instrumentation_key
  runtime_version                          = "~4"
  dotnet_version                           = "8.0"
  use_dotnet_isolated_runtime              = true

  app_settings = {}

  internal_storage = {
    enable                     = true,
    private_endpoint_subnet_id = module.private_endpoint_snet.id,
    private_dns_zone_blob_ids  = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id],
    private_dns_zone_queue_ids = [azurerm_private_dns_zone.privatelink_queue_core_windows_net.id],
    private_dns_zone_table_ids = [azurerm_private_dns_zone.privatelink_table_core_windows_net.id],
    queues                     = [],
    containers                 = [],
    blobs_retention_days       = 7
  }

  internal_storage_account_info = {
    account_kind                      = "StorageV2"
    account_tier                      = "Standard"
    account_replication_type          = "ZRS"
    access_tier                       = "Hot"
    advanced_threat_protection_enable = false
    use_legacy_defender_version       = false
    public_network_access_enabled     = false
  }

  subnet_id               = module.app_snet.id
  allowed_subnets         = [module.app_snet.id]
  app_service_plan_id     = azurerm_service_plan.app.id
  system_identity_enabled = true

  cors = {
    allowed_origins = ["https://portal.azure.com"]
  }

  tags = var.tags
}
