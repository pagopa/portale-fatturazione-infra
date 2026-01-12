# create let's encrypt credential used to create SSL certificates
module "letsencrypt_credential" {
  source = "github.com/pagopa/terraform-azurerm-v3//letsencrypt_credential?ref=v8.46.0"

  prefix            = var.prefix
  env               = var.env_short
  key_vault_name    = data.azurerm_key_vault.this.name
  subscription_name = local.subscription_name
}

# create the service connection federated with a dedicated managed identity
module "tls_cert_service_conn" {
  source = "github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_federated?ref=v9.2.1"

  project_id          = data.azuredevops_project.project.id
  name                = "${local.project}-tls-cert"
  tenant_id           = local.tenant_id
  subscription_name   = local.subscription_name
  subscription_id     = local.subscription_id
  location            = "westeurope" # italy north region does not support federated identities
  resource_group_name = data.azurerm_resource_group.identity.name
}

# allow the identity of the service connection to access keyvault certs
resource "azurerm_key_vault_access_policy" "tls_cert_service_conn_kv_access_policy" {
  key_vault_id = data.azurerm_key_vault.this.id
  tenant_id    = local.tenant_id
  object_id    = module.tls_cert_service_conn.identity_principal_id

  certificate_permissions = ["Get", "Import"]
}
