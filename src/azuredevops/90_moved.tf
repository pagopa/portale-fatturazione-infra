# moved {
#   from = azuredevops_serviceendpoint_github.azure-devops-github-ro
#   to   = azuredevops_serviceendpoint_github.github_ro
# }
# moved {
#   from = azurerm_key_vault_access_policy.tls_cert_service_conn_kv_access_policy_prod
#   to   = azurerm_key_vault_access_policy.tls_cert_service_conn_kv_access_policy
# }
# moved {
#   from = module.letsencrypt_prod.null_resource.this
#   to   = module.letsencrypt_credential.null_resource.this
# }
# moved {
#   from = module.tls_cert_service_conn_prod.data.azurerm_resource_group.default_assignment_rg
#   to   = module.tls_cert_service_conn.data.azurerm_resource_group.default_assignment_rg
# }
# moved {
#   from = module.tls_cert_service_conn_prod.azuredevops_serviceendpoint_azurerm.azurerm
#   to   = module.tls_cert_service_conn.azuredevops_serviceendpoint_azurerm.azurerm
# }
# moved {
#   from = module.tls_cert_service_conn_prod.azurerm_federated_identity_credential.federated_setup
#   to   = module.tls_cert_service_conn.azurerm_federated_identity_credential.federated_setup
# }
# moved {
#   from = module.tls_cert_service_conn_prod.azurerm_role_assignment.managed_identity_default_role_assignment
#   to   = module.tls_cert_service_conn.azurerm_role_assignment.managed_identity_default_role_assignment
# }
# moved {
#   from = module.tls_cert_service_conn_prod.azurerm_user_assigned_identity.identity
#   to   = module.tls_cert_service_conn.azurerm_user_assigned_identity.identity
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].azuredevops_build_definition.pipeline
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].azuredevops_build_definition.pipeline
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.github_service_connection_authorization
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].azuredevops_pipeline_authorization.github_service_connection_authorization
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.service_connection_ids_authorization[0]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].azuredevops_pipeline_authorization.service_connection_ids_authorization[0]
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.service_connection_le_authorization
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].azuredevops_pipeline_authorization.service_connection_le_authorization
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].azurerm_role_assignment.managed_identity_default_role_assignment
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].azurerm_role_assignment.managed_identity_default_role_assignment
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].time_sleep.wait
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].time_sleep.wait
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].azuredevops_build_definition.pipeline
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].azuredevops_build_definition.pipeline
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.github_service_connection_authorization
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].azuredevops_pipeline_authorization.github_service_connection_authorization
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.service_connection_ids_authorization[0]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].azuredevops_pipeline_authorization.service_connection_ids_authorization[0]
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].azuredevops_pipeline_authorization.service_connection_le_authorization
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].azuredevops_pipeline_authorization.service_connection_le_authorization
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].azurerm_role_assignment.managed_identity_default_role_assignment
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].azurerm_role_assignment.managed_identity_default_role_assignment
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].time_sleep.wait
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].time_sleep.wait
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.data.azurerm_resource_group.default_assignment_rg
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.azuredevops_serviceendpoint_federated.data.azurerm_resource_group.default_assignment_rg
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azuredevops_serviceendpoint_azurerm.azurerm
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.azuredevops_serviceendpoint_federated.azuredevops_serviceendpoint_azurerm.azurerm
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_federated_identity_credential.federated_setup
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.azuredevops_serviceendpoint_federated.azurerm_federated_identity_credential.federated_setup
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_role_assignment.managed_identity_default_role_assignment
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.azuredevops_serviceendpoint_federated.azurerm_role_assignment.managed_identity_default_role_assignment
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_user_assigned_identity.identity
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.azuredevops_serviceendpoint_federated.azurerm_user_assigned_identity.identity
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault.this
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.secrets.data.azurerm_key_vault.this
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault_secret.this["le-private-key-json"]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.secrets.data.azurerm_key_vault_secret.this["le-private-key-json"]
# }
# moved {
#   from = module.tlscert-api-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault_secret.this["le-regr-json"]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__api"].module.secrets.data.azurerm_key_vault_secret.this["le-regr-json"]
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.data.azurerm_resource_group.default_assignment_rg
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.azuredevops_serviceendpoint_federated.data.azurerm_resource_group.default_assignment_rg
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azuredevops_serviceendpoint_azurerm.azurerm
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.azuredevops_serviceendpoint_federated.azuredevops_serviceendpoint_azurerm.azurerm
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_federated_identity_credential.federated_setup
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.azuredevops_serviceendpoint_federated.azurerm_federated_identity_credential.federated_setup
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_role_assignment.managed_identity_default_role_assignment
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.azuredevops_serviceendpoint_federated.azurerm_role_assignment.managed_identity_default_role_assignment
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.azuredevops_serviceendpoint_federated.azurerm_user_assigned_identity.identity
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.azuredevops_serviceendpoint_federated.azurerm_user_assigned_identity.identity
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault.this
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.secrets.data.azurerm_key_vault.this
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault_secret.this["le-private-key-json"]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.secrets.data.azurerm_key_vault_secret.this["le-private-key-json"]
# }
# moved {
#   from = module.tlscert-portalefatturazione-pagopa-it-cert_az[0].module.secrets.data.azurerm_key_vault_secret.this["le-regr-json"]
#   to   = module.tlscert_renewal_pipeline["portalefatturazione.pagopa.it__"].module.secrets.data.azurerm_key_vault_secret.this["le-regr-json"]
# }
