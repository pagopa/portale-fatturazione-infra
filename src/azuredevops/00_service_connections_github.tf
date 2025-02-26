
# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "github_ro" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "azure-devops-github-ro-${var.env_short}"
  auth_personal {
    personal_access_token = module.secret_core.values[local.github_readonly_token_name].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}
