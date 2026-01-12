
resource "azurerm_public_ip" "agw" {
  name                = format("%s-%s-pip", local.project, "agw")
  resource_group_name = data.azurerm_resource_group.networking.name
  location            = data.azurerm_resource_group.networking.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = [1, 2, 3]
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "agw" {
  resource_group_name = data.azurerm_resource_group.networking.name
  location            = data.azurerm_resource_group.networking.location
  name                = format("%s-%s", local.project, "agw-id")
  tags                = var.tags
}


# read the certificate before provisioning the appgateway
data "azurerm_key_vault_certificate" "agw_api_app" {
  name         = local.cert_name_api
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_certificate" "agw_apex_app" {
  name         = local.cert_name_apex
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_certificate" "agw_storage" {
  name         = local.cert_name_storage
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_certificate" "agw_integration" {
  name         = local.cert_name_integration
  key_vault_id = data.azurerm_key_vault.main.id
}

module "agw" {
  source              = "./.terraform/modules/__v4__/app_gateway/"
  name                = format("%s-%s", local.project, "agw")
  resource_group_name = data.azurerm_resource_group.networking.name
  location            = data.azurerm_resource_group.networking.location
  # sku
  sku_name     = var.agw_sku
  sku_tier     = var.agw_sku
  sku_capacity = var.agw_autoscale ? null : 1
  waf_enabled  = var.agw_waf_enabled
  # networking
  subnet_id    = data.azurerm_subnet.agw.id
  public_ip_id = azurerm_public_ip.agw.id
  # tls config
  ssl_profiles = var.agw_sku == "Basic" ? [] : [{
    name                             = format("%s-%s", local.project, "ssl-profile")
    trusted_client_certificate_names = null
    verify_client_cert_issuer_dn     = false
    ssl_policy = {
      disabled_protocols = []
      policy_type        = "Custom"
      policy_name        = "" # with Custom type set empty policy_name (not required by the provider)
      # the following are the only allowed ciphersuites and TLS versions by tech standards
      cipher_suites = [
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
      ]
      min_protocol_version = "TLSv1_2"
    }
  }]
  trusted_client_certificates = []
  # backends
  backends = {
    app_api = {
      protocol                    = "Https"
      host                        = format("%s-%s.%s", local.project, "app-api", "azurewebsites.net")
      port                        = 443
      ip_addresses                = null # with null value use fqdns
      fqdns                       = [format("%s-%s.%s", local.project, "app-api", "azurewebsites.net")]
      probe                       = "/health"
      probe_name                  = "probe-app_api"
      request_timeout             = 300
      pick_host_name_from_backend = false # module quirk
    },
    app_fe = {
      protocol                    = "Https"
      host                        = format("%s-%s.%s", local.project, "app-fe", "azurewebsites.net")
      port                        = 443
      ip_addresses                = null # with null value use fqdns
      fqdns                       = [format("%s-%s.%s", local.project, "app-fe", "azurewebsites.net")]
      probe                       = "/health"
      probe_name                  = "probe-app_fe"
      request_timeout             = 60
      pick_host_name_from_backend = false # module quirk
    },
    # backend for the public storage account
    storage = {
      protocol     = "Https"
      host         = module.public_storage.primary_blob_host
      port         = 443
      ip_addresses = null # with null value use fqdns
      fqdns        = [module.public_storage.primary_blob_host]
      # probe targeting an ad-hoc health check blob in the public storage
      probe                       = local.public_health_blob_url
      probe_name                  = "probe-storage"
      request_timeout             = 60
      pick_host_name_from_backend = false # module quirk
    }
    # backend for the integration function app
    integration = {
      protocol     = "Https"
      host         = azurerm_linux_function_app.integration.default_hostname
      port         = 443
      ip_addresses = null # with null value use fqdns
      fqdns        = [azurerm_linux_function_app.integration.default_hostname]
      # probe targeting an ad-hoc health check blob in the public storage
      probe                       = "/"
      probe_name                  = "probe-integration"
      request_timeout             = 60
      pick_host_name_from_backend = false # module quirk
    }
  }
  # listeners
  listeners = {
    api = {
      protocol           = "Https"
      host               = local.fqdn_api
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null
      certificate = {
        name = local.cert_name_api
        id   = data.azurerm_key_vault_certificate.agw_api_app.versionless_secret_id
      }
    }
    apex = {
      protocol           = "Https"
      host               = local.fqdn_fe
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null
      certificate = {
        name = local.cert_name_apex
        id   = data.azurerm_key_vault_certificate.agw_apex_app.versionless_secret_id,
      }
    }
    # public storage listener to provide a custom hostname to that storage
    storage = {
      protocol           = "Https"
      host               = local.fqdn_storage
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null
      certificate = {
        name = local.cert_name_storage
        id   = data.azurerm_key_vault_certificate.agw_storage.versionless_secret_id
      }
    }
    integration = {
      protocol           = "Https"
      host               = local.fqdn_integration
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null
      certificate = {
        name = local.cert_name_integration
        id   = data.azurerm_key_vault_certificate.agw_integration.versionless_secret_id
      }
    }
  }
  rewrite_rule_sets = [{
    name = "integration"
    rewrite_rules = [{
      # this is because the normal X-Forwarded-For header is somehow
      # killed by the function app runtime, let's just use another header
      name          = "custom-forwarded-for"
      rule_sequence = 100
      conditions    = []
      request_header_configurations = [{
        header_name  = "Custom-Forwarded-For"
        header_value = "{var_add_x_forwarded_for_proxy}"
      }]
      response_header_configurations = []
      url                            = null
    }]
  }]
  routes = {
    api = {
      listener              = "api"
      backend               = "app_api"
      rewrite_rule_set_name = null
      priority              = 10
    }
    apex = {
      listener              = "apex"
      backend               = "app_fe"
      rewrite_rule_set_name = null
      priority              = 20
    }
    storage = {
      listener              = "storage"
      backend               = "storage"
      rewrite_rule_set_name = null
      priority              = 90
    }
    integration = {
      listener              = "integration"
      backend               = "integration"
      rewrite_rule_set_name = "integration"
      priority              = 30
    }
  }
  # identity
  identity_ids = [azurerm_user_assigned_identity.agw.id]
  # scaling
  app_gateway_min_capacity = 0
  app_gateway_max_capacity = 2
  app_gateway_autoscale    = var.agw_autoscale
  # multi-az
  zones = [1, 2, 3]
  tags  = var.tags
}

# allow agw to pull certs
resource "azurerm_key_vault_access_policy" "agw_policy" {
  key_vault_id            = data.azurerm_key_vault.main.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.agw.principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = ["Get", "List"]
}
