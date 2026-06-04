output "id" {
  value       = azurerm_linux_web_app.this.id
  description = "ID of the web app"
}

output "name" {
  value       = azurerm_linux_web_app.this.name
  description = "Name of the web app"
}

output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname of the web app"
}

output "principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "Principal ID of the system-assigned identity of the web app"
}

output "staging_principal_id" {
  value       = var.app_staging_slot_enabled ? azurerm_linux_web_app_slot.staging[0].identity[0].principal_id : null
  description = "Principal ID of the system-assigned identity of the staging slot"
}
