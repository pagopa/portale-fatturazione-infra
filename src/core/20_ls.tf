
resource "azurerm_cognitive_account" "app_ls" {
  name                          = "${local.project}-app-ls"
  custom_subdomain_name         = "${local.project}-app-ls"
  location                      = data.azurerm_resource_group.app.location
  resource_group_name           = data.azurerm_resource_group.app.name
  kind                          = "TextAnalytics"
  sku_name                      = "F0"
  public_network_access_enabled = false
  network_acls {
    default_action = "Deny"
    bypass         = "None"
  }
  tags = var.tags
}

resource "azurerm_role_assignment" "app_api_cognitiveservices_user" {
  scope                = azurerm_cognitive_account.app_ls.id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.app_api.principal_id
}

resource "azurerm_private_endpoint" "app_ls" {
  name                = format("%s-endpoint", azurerm_cognitive_account.app_ls.name)
  location            = data.azurerm_resource_group.app.location
  resource_group_name = data.azurerm_resource_group.app.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = format("%s-endpoint", azurerm_cognitive_account.app_ls.name)
    private_connection_resource_id = azurerm_cognitive_account.app_ls.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [local.privatelink_dns_zone_ids.cognitiveservices]
  }

  tags = var.tags
}
