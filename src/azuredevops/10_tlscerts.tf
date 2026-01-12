
# pipelines for renewing certs of the managed domains
module "tlscert_renewal_pipeline" {
  source = "github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert_federated?ref=v9.2.1"

  for_each = { for d in var.domains : "${d.dns_zone_name}__${d.dns_record_name}" => d }

  project_id = data.azuredevops_project.project.id
  location   = "westeurope" # italynorth not support federated credentials on managed identity

  repository                          = var.le_acme_tiny_repository
  path                                = "${var.prefix}\\TLS-Certificates"
  github_service_connection_id        = azuredevops_serviceendpoint_github.github_ro.id
  dns_zone_name                       = each.value.dns_zone_name
  dns_record_name                     = each.value.dns_record_name
  dns_zone_resource_group             = data.azurerm_resource_group.dns.name
  tenant_id                           = local.tenant_id
  subscription_id                     = local.subscription_id
  subscription_name                   = local.subscription_name
  credential_key_vault_name           = data.azurerm_key_vault.this.name
  credential_key_vault_resource_group = data.azurerm_key_vault.this.resource_group_name
  # not in identity-rg for historical reasons, changing will require
  # re-creating many resources
  managed_identity_resource_group_name = data.azurerm_resource_group.dns.name

  variables = {
    KEY_VAULT_SERVICE_CONNECTION = module.tls_cert_service_conn.service_endpoint_name
  }
  variables_secret = {}

  service_connection_ids_authorization = [module.tls_cert_service_conn.service_endpoint_id]

  schedules = {
    days_to_build              = ["Fri"]
    schedule_only_with_changes = false
    start_hours                = 6
    start_minutes              = 0
    time_zone                  = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
    branch_filter = {
      include = [var.le_acme_tiny_repository.branch_name]
      exclude = []
    }
  }

  depends_on = [module.letsencrypt_credential]
}
