module "app_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = format("%s-%s-snet", local.project, "app")
  address_prefixes                          = var.cidr_app_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = []
  delegation = {
    name = "default"
    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "app_api" {
  source              = "./.terraform/modules/__v3__/app_service/"
  name                = format("%s-%s", local.project, "app-api")
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  plan_type           = "internal"
  plan_name           = format("%s-%s", local.project, "app-api-plan")
  sku_name            = var.app_plan_sku_name
  client_cert_enabled = false
  always_on           = false
  docker_image        = "registry.hub.docker.com/nginxdemos/nginx-hello"
  docker_image_tag    = "latest"
  # FIXME
  # health_check_path   = "/status"
  vnet_integration = true
  allowed_subnets  = []
  allowed_ips      = []
  subnet_id        = module.app_snet.id
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false # disable SMB mount across scale instances of /home
    WEBSITES_PORT                       = 8080  # look at EXPOSE port in Dockerfile of container
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "app_api" {
  name                = format("%s-endpoint", module.app_api.name)
  location            = var.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = module.private_endpoint_snet.id

  private_service_connection {
    name                           = format("%s-endpoint", module.app_api.name)
    private_connection_resource_id = module.app_api.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }

  tags = var.tags
}

#
# frontend
# this will be replaced by a cdn endpoint
#
module "app_fe" {
  source              = "./.terraform/modules/__v3__/app_service/"
  name                = format("%s-%s", local.project, "app-fe")
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  plan_type           = "internal"
  plan_name           = format("%s-%s", local.project, "app-fe-plan")
  sku_name            = var.app_plan_sku_name
  client_cert_enabled = false
  always_on           = false
  docker_image        = "registry.hub.docker.com/nginxdemos/nginx-hello"
  docker_image_tag    = "latest"
  # FIXME
  # health_check_path   = "/status"
  vnet_integration = false
  allowed_subnets  = [module.agw_snet.id]
  allowed_ips      = []
  subnet_id        = module.app_snet.id
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false # disable SMB mount across scale instances of /home
    WEBSITES_PORT                       = 8080  # look at EXPOSE port in Dockerfile of container
  }
  tags = var.tags
}