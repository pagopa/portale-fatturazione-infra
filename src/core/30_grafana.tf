resource "azurerm_resource_group" "grafana_dashboard" {
  count = var.grafana_enabled ? 1 : 0

  name     = "${local.project}-grafana-dashboard-rg"
  location = "northeurope" # why?

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_dashboard_grafana" "grafana_dashboard" {
  count = var.grafana_enabled ? 1 : 0

  name                              = "${local.project}-grafana"
  resource_group_name               = azurerm_resource_group.grafana_dashboard[0].name
  location                          = "northeurope"
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  zone_redundancy_enabled           = true
  grafana_major_version             = "11"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # manual smtp config
      smtp,
    ]
  }
}
