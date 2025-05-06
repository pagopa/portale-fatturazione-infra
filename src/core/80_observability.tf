resource "azurerm_log_analytics_workspace" "law" {
  name                = format("%s-%s", local.project, "law")
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention_in_days
  daily_quota_gb      = var.law_daily_quota_gb
  tags                = var.tags
}

# Application insights
resource "azurerm_application_insights" "application_insights" {
  name                = format("%s-%s", local.project, "appinsights")
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  application_type    = "other"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = var.tags
}

# Send AGW logs to LAW in non-prod (in prod a policy will take care of it)
resource "azurerm_monitor_diagnostic_setting" "agw" {
  count = var.env_short == "p" ? 0 : 1

  name                           = azurerm_log_analytics_workspace.law.name
  target_resource_id             = module.agw.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Send API App Service logs to LAW in non-prod (in prod a policy will take care of it)
resource "azurerm_monitor_diagnostic_setting" "app_api" {
  count = var.env_short == "p" ? 0 : 1

  name                           = azurerm_log_analytics_workspace.law.name
  target_resource_id             = azurerm_linux_web_app.app_api.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    # it keeps getting changed
    ignore_changes = [log_analytics_destination_type]
  }
}

# Send FE App Service logs to LAW in non-prod (in prod a policy will take care of it)
resource "azurerm_monitor_diagnostic_setting" "app_fe" {
  count = var.env_short == "p" ? 0 : 1

  name                           = azurerm_log_analytics_workspace.law.name
  target_resource_id             = azurerm_linux_web_app.app_fe.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    # it keeps getting changed
    ignore_changes = [log_analytics_destination_type]
  }
}

# Send API Function App logs to LAW
resource "azurerm_monitor_diagnostic_setting" "func_api" {
  name                           = azurerm_log_analytics_workspace.law.name
  target_resource_id             = azurerm_linux_function_app.api.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    # it keeps getting changed
    ignore_changes = [log_analytics_destination_type]
  }
}

# Send integration Function App logs to LAW
resource "azurerm_monitor_diagnostic_setting" "func_integration" {
  name                           = azurerm_log_analytics_workspace.law.name
  target_resource_id             = azurerm_linux_function_app.integration.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    # it keeps getting changed
    ignore_changes = [log_analytics_destination_type]
  }
}
