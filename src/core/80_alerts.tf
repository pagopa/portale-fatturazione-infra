
# alert rule for SDI code modification
resource "azurerm_monitor_scheduled_query_rules_alert" "detect_sdi_code_modification" {
  name                = "[${azurerm_application_insights.application_insights.name}] SDI code modification"
  description         = "Triggered when SDI code modification is detected in application logs"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  data_source_id      = azurerm_application_insights.application_insights.id
  enabled             = true
  severity            = 3 // informational
  frequency           = var.alert_sdi_code_frequency_mins
  time_window         = var.alert_sdi_code_time_window_mins
  query_type          = "ResultCount"

  query = <<EOT
    traces
    | where message contains "Modifica Codice SDI"
    | where severityLevel == 3
    | project timestamp, message, customDimensions
    | order by timestamp desc
  EOT

  trigger {
    operator  = "GreaterThanOrEqual"
    threshold = 1
  }

  action {
    action_group  = [azurerm_monitor_action_group.notify_sdi_code_modification.id]
    email_subject = "Portale Fatturazione [${upper(var.env)}]: Modifica Codice SDI"
  }

  tags = var.tags
}

# take the destination email address from key vault
data "azurerm_key_vault_secret" "alert_sdi_code_email_address" {
  name         = "AlertSDICodeNotifyEmailAddress"
  key_vault_id = module.key_vault.id
}

# action group for notifying SDI code modification
resource "azurerm_monitor_action_group" "notify_sdi_code_modification" {
  name                = "notify-sdi-code-modification"
  short_name          = "sdi-code"
  location            = "global"
  resource_group_name = azurerm_resource_group.monitoring.name
  enabled             = true

  email_receiver {
    email_address           = data.azurerm_key_vault_secret.alert_sdi_code_email_address.value
    name                    = "notify-sdi-code-modification"
    use_common_alert_schema = false
  }

  tags = var.tags
}

