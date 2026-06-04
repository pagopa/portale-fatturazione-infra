moved {
  from = azurerm_log_analytics_workspace.log_analytics_workspace
  to   = azurerm_log_analytics_workspace.law
}


moved {
  from = module.vnet.azurerm_virtual_network.this
  to   = azurerm_virtual_network.primary
}

moved {
  from = module.secondary_vnet.azurerm_virtual_network.this
  to   = azurerm_virtual_network.secondary
}

moved {
  from = module.private_endpoint_snet.azurerm_subnet.this
  to   = azurerm_subnet.private_endpoint
}
moved {
  from = module.private_endpoint_secondary_snet.azurerm_subnet.this
  to   = azurerm_subnet.private_endpoint_secondary
}
moved {
  from = module.vpn_snet.azurerm_subnet.this
  to   = azurerm_subnet.vpn
}
moved {
  from = module.dns_fwd_snet.azurerm_subnet.this
  to   = azurerm_subnet.dns_fwd
}
moved {
  from = module.agw_snet.azurerm_subnet.this
  to   = azurerm_subnet.agw
}

moved {
  from = azurerm_resource_group.grafana_dashboard_rg
  to   = azurerm_resource_group.grafana_dashboard
}

moved {
  from = azurerm_monitor_scheduled_query_rules_alert.detect_sdi_code_modification
  to   = azurerm_monitor_scheduled_query_rules_alert.detect_sdi_code_modification[0]
}
moved {
  from = azurerm_monitor_action_group.notify_sdi_code_modification
  to   = azurerm_monitor_action_group.notify_sdi_code_modification[0]
}

moved {
  from = azurerm_resource_group.grafana_dashboard
  to   = azurerm_resource_group.grafana_dashboard[0]
}
moved {
  from = azurerm_dashboard_grafana.grafana_dashboard
  to   = azurerm_dashboard_grafana.grafana_dashboard[0]
}

# app_api hand-written resources moved into module.app_api.
# Migrates existing state to the new module addresses, avoiding destroy/recreate.
# Safe to remove once applied across all envs.
moved {
  from = azurerm_linux_web_app.app_api
  to   = module.app_api.azurerm_linux_web_app.this
}

moved {
  from = azurerm_app_service_virtual_network_swift_connection.app_api
  to   = module.app_api.azurerm_app_service_virtual_network_swift_connection.app[0]
}

moved {
  from = azurerm_private_endpoint.app_api
  to   = module.app_api.azurerm_private_endpoint.app[0]
}

moved {
  from = azurerm_linux_web_app_slot.app_api_staging[0]
  to   = module.app_api.azurerm_linux_web_app_slot.staging[0]
}

moved {
  from = azurerm_app_service_slot_virtual_network_swift_connection.app_api_staging[0]
  to   = module.app_api.azurerm_app_service_slot_virtual_network_swift_connection.staging[0]
}

moved {
  from = azurerm_private_endpoint.app_api_staging[0]
  to   = module.app_api.azurerm_private_endpoint.staging[0]
}

