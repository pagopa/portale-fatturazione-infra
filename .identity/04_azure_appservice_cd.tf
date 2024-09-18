
// TODO here a "convention over configuration" is used on naming, but some of these should be vars!
// TODO should this be put directly into portal-fatturazione-be repo?

data "azurerm_resource_group" "identity_rg" {
  name = "${local.project}-identity-rg"
}

data "azurerm_resource_group" "app_rg" {
  name = "${local.project}-app-rg"
}

data "azurerm_linux_web_app" "app_api" {
  # TODO swap container
  name                = "${local.project}-app-api-container"
  resource_group_name = data.azurerm_resource_group.app_rg.name
}

resource "azurerm_user_assigned_identity" "backend_cd" {
  resource_group_name = data.azurerm_resource_group.identity_rg.name
  location            = data.azurerm_resource_group.identity_rg.location
  name                = "${local.project}-be-cd"
}

resource "azurerm_role_assignment" "app_backend_contributor" {
  scope                = data.azurerm_resource_group.app_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.backend_cd.principal_id
}

resource "azurerm_federated_identity_credential" "backend_cd" {
  parent_id           = azurerm_user_assigned_identity.backend_cd.id
  name                = "github-federated"
  resource_group_name = data.azurerm_resource_group.identity_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github.org}/portale-fatturazione-be:environment:${var.env}"
}

# add role assignment to default roleassignment rg:
# the managed identity needs at least reader on one rg (or the whole subscription)

data "azurerm_resource_group" "default_assignment_rg" {
  name = "default-roleassignment-rg"
}

resource "azurerm_role_assignment" "managed_identity_default_role_assignment" {
  scope                = data.azurerm_resource_group.default_assignment_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.backend_cd.principal_id
}

output "id_backend_cd" {
  value = {
    id           = azurerm_user_assigned_identity.backend_cd.id
    principal_id = azurerm_user_assigned_identity.backend_cd.principal_id
    client_id    = azurerm_user_assigned_identity.backend_cd.client_id
  }
}
