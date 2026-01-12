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

