
# infrastructure for a new app-service with container runtime
# this is temporary and should replace the existing app-service
# with .NET runtime


locals {
  app_api_container = {
    app_settings = {
      APPINSIGHTS_SAMPLING_PERCENTAGE     = 5               # would have been inherited from module
      WEBSITE_DNS_SERVER                  = "168.63.129.16" # would have been inherited from module
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = false           # disable SMB mount across scale instances of /home
      WEBSITES_PORT                       = 8080            # look at EXPOSE port in Dockerfile of container
      CONNECTION_STRING                   = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ConnectionString)"
      JWT_SECRET                          = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=JwtSecret)"
      ADMIN_KEY                           = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=AdminKey)"
      JWT_VALID_AUDIENCE                  = "${format("%s-%s", local.project, "app-api-container")}.azurewebsites.net"
      JWT_VALID_ISSUER                    = "${format("%s-%s", local.project, "app-api-container")}.azurewebsites.net"
      KEY_VAULT_NAME                      = module.key_vault_app.name
      SELFCARE_CERT_ENDPOINT              = "/.well-known/jwks.json"
      SELF_CARE_URI                       = var.app_api_config_selfcare_url
      SELF_CARE_TIMEOUT                   = false
      SELF_CARE_AUDIENCE                  = "${var.dns_zone_portalefatturazione_prefix}.${var.dns_external_domain}"
      # CORS_ORIGINS is used to prevent the API execution in case it is called by the "wrong" frontend
      # out-of-the-box CORS does not prevent the execution, it prevents the browser to read the answer
      CORS_ORIGINS             = "https://${var.dns_zone_portalefatturazione_prefix}.${var.dns_external_domain}"
      APPLICATION_INSIGHTS     = azurerm_application_insights.application_insights.connection_string
      AZUREAD_INSTANCE         = "https://login.microsoftonline.com/"
      AZUREAD_TENANTID         = data.azurerm_client_config.current.tenant_id
      AZUREAD_CLIENTID         = data.azuread_application.portalefatturazione.application_id
      AZUREAD_ADGROUP          = "fat-${var.env_short}-adgroup-"
      STORAGE_CONNECTIONSTRING = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=RelStorageConnectionString)"
      STORAGE_REL_FOLDER       = "rel"
    }
  }
}

# api
resource "azurerm_linux_web_app" "app_api_container" {
  name                          = format("%s-%s", local.project, "app-api-container")
  location                      = azurerm_resource_group.app.location
  resource_group_name           = azurerm_resource_group.app.name
  service_plan_id               = azurerm_service_plan.app.id
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = true

  app_settings = local.app_api_container.app_settings

  site_config {
    always_on               = true
    use_32_bit_worker       = false
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
    health_check_path       = "/health"

    application_stack {
      docker_image_name   = "pagopa/portale-fatturazione-be:latest" // ignored, will be managed from ci/cd pipeline
      docker_registry_url = "https://ghcr.io"
    }
    cors {
      allowed_origins = [
        # ACAO header is schema aware (https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin)
        "https://${var.dns_zone_portalefatturazione_prefix}.${var.dns_external_domain}"
      ]
      support_credentials = true
    }
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker_image_name
    ]
  }
  tags = var.tags
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "app_api_container" {
  app_service_id = azurerm_linux_web_app.app_api_container.id
  subnet_id      = module.app_snet.id
}

# private endpoint
resource "azurerm_private_endpoint" "app_api_container" {
  name                = format("%s-endpoint", azurerm_linux_web_app.app_api_container.name)
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_web_app.app_api_container.name)
    private_connection_resource_id = azurerm_linux_web_app.app_api_container.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}

# policy for app service access (api)
resource "azurerm_key_vault_access_policy" "app_api_container_policy" {
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app.app_api_container.identity[0].principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = []
}

# slot
resource "azurerm_linux_web_app_slot" "app_api_container_staging" {
  app_service_id                = azurerm_linux_web_app.app_api_container.id
  name                          = "staging"
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = true

  app_settings = local.app_api_container.app_settings

  site_config {
    always_on               = true
    use_32_bit_worker       = false
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
    health_check_path       = "/health"

    application_stack {
      docker_image_name   = "pagopa/portale-fatturazione-be:latest" // ignored, will be managed from ci/cd pipeline
      docker_registry_url = "https://ghcr.io"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker_image_name
    ]
  }
  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "app_api_container_staging_policy" {
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app_slot.app_api_container_staging.identity[0].principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = []
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_api_container_staging" {
  slot_name      = azurerm_linux_web_app_slot.app_api_container_staging.name
  app_service_id = azurerm_linux_web_app.app_api_container.id
  subnet_id      = module.app_snet.id
}
