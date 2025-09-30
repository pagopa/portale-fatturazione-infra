locals {
  app_api = {
    app_settings = {
      APPINSIGHTS_SAMPLING_PERCENTAGE     = 5               # would have been inherited from module
      WEBSITE_DNS_SERVER                  = "168.63.129.16" # would have been inherited from module
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = false           # disable SMB mount across scale instances of /home
      WEBSITES_PORT                       = 8080            # look at EXPOSE port in Dockerfile of container
      ASPNETCORE_ENVIRONMENT              = "Production"
      CONNECTION_STRING                   = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=ConnectionString)"
      JWT_SECRET                          = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=JwtSecret)"
      ADMIN_KEY                           = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=AdminKey)"
      JWT_VALID_AUDIENCE                  = local.fqdn_api
      JWT_VALID_ISSUER                    = local.fqdn_api
      KEY_VAULT_NAME                      = data.azurerm_key_vault.app.name
      SELFCARE_CERT_ENDPOINT              = "/.well-known/jwks.json"
      SELF_CARE_URI                       = var.app_api_config_selfcare_url
      SELF_CARE_TIMEOUT                   = var.env_short == "p"
      SELF_CARE_AUDIENCE                  = "${var.dns_zone_portalefatturazione_prefix}.${var.dns_external_domain}"
      # CORS_ORIGINS is used to prevent the API execution in case it is called by the "wrong" frontend
      # out-of-the-box CORS does not prevent the execution, it prevents the browser to read the answer
      CORS_ORIGINS = "https://${var.dns_zone_portalefatturazione_prefix}.${var.dns_external_domain}"

      # appinsights
      APPLICATION_INSIGHTS                            = azurerm_application_insights.application_insights.connection_string
      APPINSIGHTS_INSTRUMENTATIONKEY                  = azurerm_application_insights.application_insights.instrumentation_key
      APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
      APPLICATIONINSIGHTS_CONNECTION_STRING           = azurerm_application_insights.application_insights.connection_string
      APPLICATIONINSIGHTS_ENABLESQLQUERYCOLLECTION    = "disabled"
      DISABLE_APPINSIGHTS_SDK                         = "disabled"
      IGNORE_APPINSIGHTS_SDK                          = "disabled"
      ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
      DiagnosticServices_EXTENSION_VERSION            = "~3"
      InstrumentationEngine_EXTENSION_VERSION         = "disabled"
      SnapshotDebugger_EXTENSION_VERSION              = "disabled"
      XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
      XDT_MicrosoftApplicationInsights_Mode           = "recommended"
      XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"

      # application
      AZUREAD_INSTANCE         = "https://login.microsoftonline.com/"
      AZUREAD_TENANTID         = data.azurerm_client_config.current.tenant_id
      AZUREAD_CLIENTID         = data.azuread_application.portalefatturazione.application_id
      AZUREAD_ADGROUP          = "fat-${var.env_short}-adgroup-"
      STORAGE_CONNECTIONSTRING = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=RelStorageConnectionString)"
      STORAGE_REL_FOLDER       = "rel"

      STORAGE_DOCUMENTI_CONNECTIONSTRING = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=DlsStorageConnectionString)"
      STORAGE_DOCUMENTI_FOLDER           = "reportaccertamenti"
      SYNAPSE_WORKSPACE_NAME             = azurerm_synapse_workspace.this.name
      PIPELINE_NAME_SAP                  = "SendJsonToSap",
      SYNAPSE_SUBSCRIPTIONID             = data.azurerm_client_config.current.subscription_id
      SYNAPSE_RESOURCEGROUPNAME          = azurerm_synapse_workspace.this.resource_group_name

      STORAGE_FINANCIAL_ACCOUNTNAME   = module.public_storage.name
      STORAGE_FINANCIAL_ACCOUNTKEY    = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=PublicStorageKey)"
      STORAGE_FINANCIAL_CONTAINERNAME = "invoices"

      SELFCAREONBOARDING_ENDPOINT  = local.selfcare_url
      SELFCAREONBOARDING_URI       = "/external/billing-portal/v1/institutions/onboarding/recipientCode/verification"
      SELFCAREONBOARDING_AUTHTOKEN = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=SelfCareAuthToken)"
      SUPPORTAPISERVICE_ENDPOINT   = local.selfcare_url
      SUPPORTAPISERVICE_URI        = "/external/billing-portal/v1/onboarding/{onboardingId}/recipient-code"
      SUPPORTAPISERVICE_AUTHTOKEN  = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=SupportApiServiceAuthToken)"

      StorageRELAccountKey        = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=PublicStorageKey)"
      StorageRELAccountName       = module.public_storage.name
      StorageRELBlobContainerName = "relrighe"
      StorageRELCustomDns         = "https://${local.fqdn_storage}"

      StorageNotificheAccountName       = module.public_storage.name
      StorageNotificheAccountKey        = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=PublicStorageKey)"
      StorageNotificheBlobContainerName = "notifiche"
      StorageNotificheCustomDNS         = "https://${local.fqdn_storage}",
      AzureFunctionNotificheUri         = "https://${azurerm_linux_function_app.api.default_hostname}/api/RichiestaNotificheHandler"
      # TODO use managed identity
      AzureFunctionAppKey = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.app.name};SecretName=synapse-sendemail-fnkey)"
    }
  }
}

# plan
resource "azurerm_service_plan" "app" {
  name                     = format("%s-%s", local.project, "app-plan")
  location                 = data.azurerm_resource_group.app.location
  resource_group_name      = data.azurerm_resource_group.app.name
  sku_name                 = var.app_plan_sku_name
  worker_count             = 3
  os_type                  = "Linux"
  per_site_scaling_enabled = false
  zone_balancing_enabled   = true
  tags                     = var.tags
}

# frontend
# this will be replaced by a cdn endpoint in the near future
resource "azurerm_linux_web_app" "app_fe" {
  name                       = format("%s-%s", local.project, "app-fe")
  location                   = data.azurerm_resource_group.app.location
  resource_group_name        = data.azurerm_resource_group.app.name
  service_plan_id            = azurerm_service_plan.app.id
  client_certificate_enabled = false
  https_only                 = true
  client_affinity_enabled    = false
  app_settings = {
    APPINSIGHTS_SAMPLING_PERCENTAGE     = 5               # would have been inherited from module
    WEBSITE_DNS_SERVER                  = "168.63.129.16" # would have been inherited from module
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false           # disable SMB mount across scale instances of /home
    WEBSITES_PORT                       = 8080            # look at EXPOSE port in Dockerfile of container
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    APPLICATION_INSIGHTS                = azurerm_application_insights.application_insights.connection_string
  }

  site_config {
    always_on                         = true
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    app_command_line                  = "pm2 serve /home/site/wwwroot --no-daemon --spa"
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Allow"

    application_stack {
      node_version = "22-lts"
    }
    ip_restriction {
      virtual_network_subnet_id = data.azurerm_subnet.agw.id
      name                      = "rule"
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
  tags = var.tags
}

locals {
  selfcare_url = format("https://api.%sselfcare.pagopa.it", var.env_short == "p" ? "" : "${var.env}.")
}

# api
resource "azurerm_linux_web_app" "app_api" {
  name                          = format("%s-%s", local.project, "app-api")
  location                      = data.azurerm_resource_group.app.location
  resource_group_name           = data.azurerm_resource_group.app.name
  service_plan_id               = azurerm_service_plan.app.id
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = false

  app_settings = local.app_api.app_settings

  site_config {
    always_on                         = true
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2

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
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      logs[0].http_logs[0].file_system[0].retention_in_days, # keeps getting change, tired of it
      site_config[0].application_stack[0].docker_image_name,
      site_config[0].application_stack[0].docker_registry_url, # weird bug, better leaving this off
    ]
  }

  tags = var.tags
}

# allow app service to pull secrets from kv
resource "azurerm_key_vault_access_policy" "app_api_policy" {
  key_vault_id            = data.azurerm_key_vault.app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app.app_api.identity[0].principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = []
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

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "app_api" {
  app_service_id = azurerm_linux_web_app.app_api.id
  subnet_id      = data.azurerm_subnet.app.id
}

# private endpoint
resource "azurerm_private_endpoint" "app_api" {
  name                = format("%s-endpoint", azurerm_linux_web_app.app_api.name)
  location            = data.azurerm_resource_group.app.location
  resource_group_name = data.azurerm_resource_group.app.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_web_app.app_api.name)
    private_connection_resource_id = azurerm_linux_web_app.app_api.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.appservice]
  }
  tags = var.tags
}

resource "azurerm_linux_web_app_slot" "app_api_staging" {
  app_service_id                = azurerm_linux_web_app.app_api.id
  name                          = "staging"
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = false

  app_settings = local.app_api.app_settings

  site_config {
    always_on                         = true
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2

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
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      logs[0].http_logs[0].file_system[0].retention_in_days, # keeps getting change, tired of it
      site_config[0].application_stack[0].docker_image_name,
      site_config[0].application_stack[0].docker_registry_url, # weird bug, better leaving this off
    ]
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "app_api_staging_policy" {
  key_vault_id            = data.azurerm_key_vault.app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app_slot.app_api_staging.identity[0].principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = []
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_api_staging" {
  slot_name      = azurerm_linux_web_app_slot.app_api_staging.name
  app_service_id = azurerm_linux_web_app.app_api.id
  subnet_id      = data.azurerm_subnet.app.id

  depends_on = [azurerm_linux_web_app_slot.app_api_staging]
}

resource "azurerm_private_endpoint" "app_api_staging" {
  name                = "${azurerm_linux_web_app.app_api.name}-${azurerm_linux_web_app_slot.app_api_staging.name}-endpoint"
  location            = data.azurerm_resource_group.app.location
  resource_group_name = data.azurerm_resource_group.app.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id
  private_service_connection {
    name                           = "${azurerm_linux_web_app.app_api.name}-${azurerm_linux_web_app_slot.app_api_staging.name}-endpoint"
    private_connection_resource_id = azurerm_linux_web_app.app_api.id
    is_manual_connection           = false
    # https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint#conceptual-overview
    subresource_names = ["sites-${azurerm_linux_web_app_slot.app_api_staging.name}"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.appservice]
  }
  tags = var.tags
}
