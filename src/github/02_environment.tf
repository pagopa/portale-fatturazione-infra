locals {
  env_repo_flat = flatten([
    for r in var.repositories : [
      for e in r.environments : {
        repo = r
        env  = e
      }
    ]
  ])
  env_repo_var_flat = flatten([
    for er in local.env_repo_flat : [
      for k, v in er.env.variables : {
        repo      = er.repo
        env       = er.env
        var_name  = k
        var_value = v
      }
    ]
  ])
}

# environments configured from variable
resource "github_repository_environment" "this" {
  for_each = {
    for er in local.env_repo_flat :
    join("##", [er.repo.name, er.env.name]) => er
  }

  # general
  environment         = each.value.env.name
  repository          = each.value.repo.name
  prevent_self_review = true
  can_admins_bypass   = true

  # can only be deployed from protected branches
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  # require approval by relevant teams
  dynamic "reviewers" {
    for_each = length(each.value.env.require_review_by_teams) > 0 ? ["dummy"] : []
    content {
      teams = [
        for t in each.value.env.require_review_by_teams :
        data.github_team.all[t].id
      ]
    }
  }

  depends_on = [github_repository.this]
}

# variables in each environment
resource "github_actions_environment_variable" "this" {
  for_each = {
    for erv in local.env_repo_var_flat :
    join("##", [erv.repo.name, erv.env.name, erv.var_name]) => erv
  }

  repository    = each.value.repo.name
  environment   = each.value.env.name
  variable_name = each.value.var_name
  value         = each.value.var_value

  depends_on = [github_repository_environment.this]
}
