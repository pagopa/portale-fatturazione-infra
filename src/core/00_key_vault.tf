module "key_vault" {
  source                     = "./.terraform/modules/__v4__/key_vault/"
  name                       = format("%s-%s", local.project, "kv")
  location                   = azurerm_resource_group.kv.location
  resource_group_name        = azurerm_resource_group.kv.name
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  sku_name                   = var.kv_sku_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  tags                       = var.tags
}

#
# policy admins
#
resource "azurerm_key_vault_access_policy" "adgroup_admins_policy" {
  key_vault_id = module.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_group.adgroup_admins.object_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}

#
# policy developers
#
resource "azurerm_key_vault_access_policy" "adgroup_developers_policy" {
  key_vault_id            = module.key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_developers.object_id
  key_permissions         = var.env_short == "d" ? ["Get", "List", "Update", "Create", "Import", "Delete", ] : ["Get", "List", "Update", "Create", "Import", ]
  secret_permissions      = var.env_short == "d" ? ["Get", "List", "Set", "Delete", ] : ["Get", "List", "Set", ]
  storage_permissions     = []
  certificate_permissions = var.env_short == "d" ? ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ] : ["Get", "List", "Update", "Create", "Import", "Restore", "Recover", ]
}

#
# policy externals
#
resource "azurerm_key_vault_access_policy" "adgroup_externals_policy" {
  count                   = var.env_short == "d" ? 1 : 0
  key_vault_id            = module.key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_externals.object_id
  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}

#
# policy security
#
resource "azurerm_key_vault_access_policy" "adgroup_security_policy" {
  count                   = var.env_short == "d" ? 1 : 0
  key_vault_id            = module.key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_security.object_id
  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}

#
# policy agw
#
resource "azurerm_key_vault_access_policy" "agw_policy" {
  key_vault_id            = module.key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.agw.principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = ["Get", "List"]
}

#
# additional kv for app secrets
#
module "key_vault_app" {
  source                     = "./.terraform/modules/__v4__/key_vault/"
  name                       = format("%s-%s", local.project, "kv-app")
  location                   = azurerm_resource_group.kv.location
  resource_group_name        = azurerm_resource_group.kv.name
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  sku_name                   = var.kv_sku_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  tags                       = var.tags
}

# policy for app service access (api)
resource "azurerm_key_vault_access_policy" "app_api_policy" {
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app.app_api.identity[0].principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  storage_permissions     = []
  certificate_permissions = []
}

#
# policy admins
#
resource "azurerm_key_vault_access_policy" "adgroup_admins_policy_app" {
  key_vault_id = module.key_vault_app.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_group.adgroup_admins.object_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}

#
# policy developers
#
resource "azurerm_key_vault_access_policy" "adgroup_developers_policy_app" {
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_developers.object_id
  key_permissions         = var.env_short == "d" ? ["Get", "List", "Update", "Create", "Import", "Delete", ] : ["Get", "List", "Update", "Create", "Import", ]
  secret_permissions      = var.env_short == "d" ? ["Get", "List", "Set", "Delete", ] : ["Get", "List", "Set", ]
  storage_permissions     = []
  certificate_permissions = var.env_short == "d" ? ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ] : ["Get", "List", "Update", "Create", "Import", "Restore", "Recover", ]
}

#
# policy externals
#
resource "azurerm_key_vault_access_policy" "adgroup_externals_policy_app" {
  count                   = var.env_short == "d" ? 1 : 0
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_externals.object_id
  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}

#
# policy security
#
resource "azurerm_key_vault_access_policy" "adgroup_security_policy_app" {
  count                   = var.env_short == "d" ? 1 : 0
  key_vault_id            = module.key_vault_app.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.adgroup_security.object_id
  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", "ManageContacts", ]
}
