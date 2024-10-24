locals {
  all_bypasser_teams = toset(flatten([
    for r in var.repositories : [
      for ag in r.rule_bypassing_teams : ag
    ]
  ]))
  all_reviewer_teams = toset(flatten([
    for r in var.repositories : [
      for env in r.environments : env.require_review_by_teams
    ]
  ]))
  all_teams = setunion(local.all_bypasser_teams, local.all_reviewer_teams)
}

data "github_team" "all" {
  for_each = local.all_teams

  slug = each.key
}
