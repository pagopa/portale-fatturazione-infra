module "agw_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = format("%s-%s-snet", local.project, "agw")
  address_prefixes                          = var.cidr_agw_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = ["Microsoft.Web"]
}

resource "azurerm_public_ip" "agw" {
  name                = format("%s-%s-pip", local.project, "agw")
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = [1, 2, 3]
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "agw" {
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  name                = format("%s-%s", local.project, "agw-id")
  tags                = var.tags
}


# read the certificate before provisioning the appgateway
data "azurerm_key_vault_certificate" "agw_api_app" {
  name         = var.agw_api_app_certificate_name
  key_vault_id = module.key_vault.id
}

data "azurerm_key_vault_certificate" "agw_apex_app" {
  name         = var.agw_apex_app_certificate_name
  key_vault_id = module.key_vault.id
}

module "agw" {
  source              = "./.terraform/modules/__v3__/app_gateway/"
  name                = format("%s-%s", local.project, "agw")
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  # sku
  sku_name    = var.agw_sku
  sku_tier    = var.agw_sku
  waf_enabled = var.agw_waf_enabled
  # networking
  subnet_id    = module.agw_snet.id
  public_ip_id = azurerm_public_ip.agw.id
  # tls config
  ssl_profiles = [{
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
      request_timeout             = 60
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
        name = var.agw_api_app_certificate_name
        id = replace(
          data.azurerm_key_vault_certificate.agw_api_app.secret_id,
          "/${data.azurerm_key_vault_certificate.agw_api_app.version}",
          ""
        )
      }
    }
    apex = {
      protocol           = "Https"
      host               = local.fqdn_fe
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null
      certificate = {
        name = var.agw_apex_app_certificate_name
        id = replace(
          data.azurerm_key_vault_certificate.agw_apex_app.secret_id,
          "/${data.azurerm_key_vault_certificate.agw_apex_app.version}",
          ""
        )
      }
    }
  }
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
  }
  # identity
  identity_ids = [azurerm_user_assigned_identity.agw.id]
  # scaling
  app_gateway_min_capacity = 0
  app_gateway_max_capacity = 2
  # multi-az
  zones = [1, 2, 3]
  tags  = var.tags
}
