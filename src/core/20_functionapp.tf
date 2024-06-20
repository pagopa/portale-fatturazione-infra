
resource "azurerm_storage_account" "function_send_email" {
  name                     = replace("${local.project}sendemailsa", "-", "")
  location                 = azurerm_resource_group.app.location
  resource_group_name      = azurerm_resource_group.app.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
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
    APPINSIGHTS_SAMPLING_PERCENTAGE = 5               # would have been inherited from module
    WEBSITE_DNS_SERVER              = "168.63.129.16" # would have been inherited from module
    APPLICATION_INSIGHTS            = azurerm_application_insights.application_insights.connection_string

    CONNECTION_STRING = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ConnectionString)"
    SMTP              = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=Smtp)"
    SMTP_PORT         = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpPort)"
    SMTP_AUTH         = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpAuth)"
    SMTP_PASSWORD     = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=SmtpPassword)"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].dotnet_version
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
