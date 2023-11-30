module "app_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = format("%s-%s-snet", local.project, "app")
  address_prefixes                          = var.cidr_app_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = []
  delegation = {
    name = "default"
    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# plan
resource "azurerm_service_plan" "app" {
  name                     = format("%s-%s", local.project, "app-plan")
  location                 = azurerm_resource_group.app.location
  resource_group_name      = azurerm_resource_group.app.name
  sku_name                 = var.app_plan_sku_name
  os_type                  = "Linux"
  per_site_scaling_enabled = false
  zone_balancing_enabled   = true
  tags                     = var.tags
}

# frontend
# this will be replaced by a cdn endpoint in the near future
resource "azurerm_linux_web_app" "app_fe" {
  name                       = format("%s-%s", local.project, "app-fe")
  location                   = azurerm_resource_group.app.location
  resource_group_name        = azurerm_resource_group.app.name
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
  }

  site_config {
    always_on               = false
    use_32_bit_worker       = false
    ftps_state              = "Disabled"
    http2_enabled           = true
    app_command_line        = "pm2 serve /home/site/wwwroot --no-daemon --spa"
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
    health_check_path       = "/health"

    application_stack {
      node_version = "18-lts"
    }
    ip_restriction {
      virtual_network_subnet_id = module.agw_snet.id
      name                      = "rule"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# api
resource "azurerm_linux_web_app" "app_api" {
  name                       = format("%s-%s", local.project, "app-api")
  location                   = azurerm_resource_group.app.location
  resource_group_name        = azurerm_resource_group.app.name
  service_plan_id            = azurerm_service_plan.app.id
  client_certificate_enabled = false
  https_only                 = true
  client_affinity_enabled    = false

  app_settings = {
    APPINSIGHTS_SAMPLING_PERCENTAGE     = 5               # would have been inherited from module
    WEBSITE_DNS_SERVER                  = "168.63.129.16" # would have been inherited from module
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false           # disable SMB mount across scale instances of /home
    WEBSITES_PORT                       = 8080            # look at EXPOSE port in Dockerfile of container
    CONNECTION_STRING                   = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=ConnectionString)"
    JWT_SECRET                          = "@Microsoft.KeyVault(VaultName=${module.key_vault_app.name};SecretName=JwtSecret)"
    JWT_VALID_AUDIENCE                  = "${format("%s-%s", local.project, "app-api")}.azurewebsites.net"
    JWT_VALID_ISSUER                    = "${format("%s-%s", local.project, "app-api")}.azurewebsites.net"
    KEY_VAULT_NAME                      = module.key_vault_app.name
    SELFCARE_CERT_ENDPOINT              = "/.well-known/jwks.json"
    SELF_CARE_URI                       = "https://uat.selfcare.pagopa.it" # TODO Fixme with https://selfcare.pagopa.it and set as variable
  }

  site_config {
    always_on               = false
    use_32_bit_worker       = false
    ftps_state              = "Disabled"
    http2_enabled           = true
    app_command_line        = "dotnet PortaleFatture.BE.Api.dll"
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
    health_check_path       = "/health"

    application_stack {
      dotnet_version = "7.0" # FIXME
      # dotnet_version is ignored
      # wait https://github.com/hashicorp/terraform-provider-azurerm/commit/73832251e80c390a139688097ffdad3f2f2022e8
    }
    cors {
      allowed_origins = [
        join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
      ]
      support_credentials = true
    }
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
  tags = var.tags
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "app_api" {
  app_service_id = azurerm_linux_web_app.app_api.id
  subnet_id      = module.app_snet.id
}

# private endpoint
resource "azurerm_private_endpoint" "app_api" {
  name                = format("%s-endpoint", azurerm_linux_web_app.app_api.name)
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id
  private_service_connection {
    name                           = format("%s-endpoint", azurerm_linux_web_app.app_api.name)
    private_connection_resource_id = azurerm_linux_web_app.app_api.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }
  tags = var.tags
}