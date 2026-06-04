locals {
  default_app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.appinsights_instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.appinsights_connection_string
    WEBSITES_PORT                         = var.app_port
    WEBSITE_DNS_SERVER                    = "168.63.129.16" # use Azure-provided DNS
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = false           # disable SMB mount across scale instances of /home
    # TODO
    # WEBSITE_SWAP_WARMUP_PING_PATH              = var.health_check_path
    # WEBSITE_SWAP_WARMUP_PING_STATUSES          = 200
  }
}

# main web app
resource "azurerm_linux_web_app" "this" {
  name                                           = var.name
  location                                       = var.location
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = var.service_plan_id
  client_certificate_enabled                     = false
  https_only                                     = true
  client_affinity_enabled                        = var.client_affinity_enabled
  public_network_access_enabled                  = var.public_network_access_enabled
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  app_settings = merge(local.default_app_settings, var.custom_app_settings)

  dynamic "sticky_settings" {
    for_each = length(var.sticky_app_setting_names) > 0 ? [1] : []
    content {
      app_setting_names = var.sticky_app_setting_names
    }
  }

  site_config {
    always_on                         = var.always_on
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 2

    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
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

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack,
      logs[0].http_logs[0].file_system[0].retention_in_days,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

# vnet integration
resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  count = var.subnet_id != null ? 1 : 0

  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.subnet_id
}

# private endpoint
resource "azurerm_private_endpoint" "app" {
  count = var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "${azurerm_linux_web_app.this.name}-endpoint"
  location            = azurerm_linux_web_app.this.location
  resource_group_name = azurerm_linux_web_app.this.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  private_service_connection {
    name                           = "${azurerm_linux_web_app.this.name}-endpoint"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_link_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "private-dns-zone-group"
      private_dns_zone_ids = var.private_link_dns_zone_ids
    }
  }
  tags = var.tags
}

# optional staging slot for the web app
resource "azurerm_linux_web_app_slot" "staging" {
  count = var.app_staging_slot_enabled ? 1 : 0

  app_service_id = azurerm_linux_web_app.this.id
  name           = "staging"

  client_certificate_enabled                     = false
  https_only                                     = true
  client_affinity_enabled                        = var.client_affinity_enabled
  public_network_access_enabled                  = var.public_network_access_enabled
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  app_settings = merge(local.default_app_settings, var.custom_app_settings)

  site_config {
    always_on                         = var.always_on
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 2

    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
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

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack,
      logs[0].http_logs[0].file_system[0].retention_in_days,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

# staging slot vnet integration
resource "azurerm_app_service_slot_virtual_network_swift_connection" "staging" {
  count = var.app_staging_slot_enabled && var.subnet_id != null ? 1 : 0

  slot_name      = azurerm_linux_web_app_slot.staging[0].name
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.subnet_id
}

# staging slot private endpoint
resource "azurerm_private_endpoint" "staging" {
  count = var.app_staging_slot_enabled && var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "${azurerm_linux_web_app.this.name}-${azurerm_linux_web_app_slot.staging[0].name}-endpoint"
  location            = azurerm_linux_web_app.this.location
  resource_group_name = azurerm_linux_web_app.this.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  private_service_connection {
    name                           = "${azurerm_linux_web_app.this.name}-${azurerm_linux_web_app_slot.staging[0].name}-endpoint"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites-${azurerm_linux_web_app_slot.staging[0].name}"]
  }
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_link_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "private-dns-zone-group"
      private_dns_zone_ids = var.private_link_dns_zone_ids
    }
  }
  tags = var.tags
}
