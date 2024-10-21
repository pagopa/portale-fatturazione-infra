
# compliant branch protection rules for each repo
resource "github_branch_protection" "this" {
  for_each = { for r in var.repositories : r.name => r }

  repository_id = github_repository.this[each.value.name].node_id

  pattern          = "main"
  enforce_admins   = true
  allows_deletions = true

  required_linear_history = true

  # require pull request review by code owners
  required_pull_request_reviews {
    require_code_owner_reviews = true
    dismiss_stale_reviews      = true
    restrict_dismissals        = true
    # allow selected teams to bypass
    pull_request_bypassers = [
      for t in each.value.rule_bypassing_teams :
      data.github_team.all[t].node_id
    ]
  }

  # restrict push to main to everyone (except selected teams)
  restrict_pushes {
    push_allowances = [
      for t in each.value.rule_bypassing_teams :
      data.github_team.all[t].node_id
    ]
  }

  # forbid force push to everyone (except selected teams)
  allows_force_pushes = false
  force_push_bypassers = [
    for t in each.value.rule_bypassing_teams :
    data.github_team.all[t].node_id
  ]
}
