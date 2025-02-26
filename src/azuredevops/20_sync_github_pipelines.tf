
data "azuredevops_git_repository" "repo" {
  for_each = { for repo in var.repos_to_sync : repo.name => repo }

  project_id = data.azuredevops_project.project.id
  name       = each.value.name
}

resource "azuredevops_build_definition" "sync_repo_to_github" {
  for_each = { for repo in var.repos_to_sync : repo.name => repo }

  project_id = data.azuredevops_project.project.id
  name       = "sync-${each.value.name}-to-github"
  path       = "\\${var.prefix}\\GitHub-Sync"

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.repo[each.value.name].id
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
    value          = "${each.value.organization}/${each.value.name}"
    allow_override = false
  }

  ci_trigger {
    use_yaml = true
  }

  lifecycle {
    ignore_changes = [variable]
  }
}
