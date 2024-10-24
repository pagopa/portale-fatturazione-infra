
# github repositories declared in variable with compliant configuration
resource "github_repository" "this" {
  for_each = { for r in var.repositories : r.name => r }

  # general
  name         = each.value.name
  description  = each.value.description
  visibility   = each.value.visibility
  homepage_url = each.value.homepage_url
  archived     = each.value.archived
  topics       = setunion(each.value.topics, toset([lower(var.service_line)]))

  # security
  vulnerability_alerts = true

  # features
  has_downloads   = true
  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  # merge settings
  allow_merge_commit        = false
  allow_rebase_merge        = false
  allow_squash_merge        = true
  allow_update_branch       = true
  squash_merge_commit_title = "PR_TITLE"
  delete_branch_on_merge    = true

  # template settings
  is_template = each.value.is_template
  dynamic "template" {
    for_each = each.value.from_template == null ? [] : [1]
    content {
      owner                = split("/", each.value.from_template)[0]
      repository           = split("/", each.value.from_template)[1]
      include_all_branches = false
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [topics] ## todo workaround for https://github.com/integrations/terraform-provider-github/pull/2397
  }
}
