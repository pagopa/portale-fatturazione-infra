resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
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
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  tags                = var.tags
}