module "cdn" {
  source                           = "./.terraform/modules/__v3__/cdn/"
  # unfortunately, the module will create some ugly resource names
  # like, fat-p-cdn-cdn-endpoint, as in "${var.prefix}-${var.name}-cdn-endpoint"
  name                             = "cdn" 
  resource_group_name              = azurerm_resource_group.cdn.name
  location                         = var.secondary_location
  storage_account_replication_type = var.cdn_storage_account_replication_type
  prefix                           = local.project
  dns_zone_name                    = azurerm_dns_zone.portalefatturazione[0].name
  dns_zone_resource_group_name     = azurerm_resource_group.networking.name
  hostname                         = join(".", [var.dns_zone_portalefatturazione_prefix, var.dns_external_domain])
  keyvault_vault_name              = module.key_vault.name
  keyvault_subscription_id         = data.azurerm_subscription.current.subscription_id
  keyvault_resource_group_name     = module.key_vault.resource_group_name
  index_document                   = "index.html"
  error_404_document               = "404.html"
  tags                             = var.tags
}