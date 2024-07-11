
variable "repos_to_sync" {
  description = "Repository to sync to GitHub"
  type = list(object({
    organization = string
    name         = string
    branch_name  = string
    yml_path     = string
  }))
  default = [
    {
      organization = "pagopa"
      name         = "portale-fatturazione-be"
      branch_name  = "refs/heads/master"
      yml_path     = "azure-pipelines.yml"
    },
    {
      organization = "pagopa"
      name         = "portale-fatturazione-fe"
      branch_name  = "refs/heads/master"
      yml_path     = "azure-pipelines.yml"
    },
    {
      organization = "pagopa"
      name         = "portale-fatturazione-synapse"
      branch_name  = "refs/heads/master"
      yml_path     = "azure-pipelines.yml"
    },
  ]
}

resource "azuredevops_build_definition" "sync_backend_to_github" {
  for_each = { for repo in var.repos_to_sync : "${repo.organization}/${repo.name}" => repo }

  project_id = data.azuredevops_project.project.id
  name       = "sync-backend"
  path       = "${var.prefix}\\GitHub-Sync"

  repository {
    repo_type   = "GitHub"
    repo_id     = "${each.value.organization}/${each.value.name}"
    branch_name = each.value.branch_name
    yml_path    = each.value.yml_path
  }

  variable {
    name           = "GITHUB_PAT"
    secret_value   = module.secret_core.values["azure-devops-github-rw-TOKEN"].value
    is_secret      = true
    allow_override = false
  }

  variable {
    name           = "GITHUB_REPO"
    value          = "pagopa/portale-fatturazione-be"
    allow_override = false
  }

  ci_trigger {
    use_yaml = true
  }
}
