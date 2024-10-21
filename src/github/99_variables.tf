
variable "service_line" {
  type        = string
  description = "name of the service line"
}

variable "repositories" {
  type = list(object({
    name                 = string
    description          = string
    visibility           = string
    topics               = optional(set(string), null)
    homepage_url         = optional(string, null)
    from_template        = optional(string, null)
    is_template          = optional(bool, false)
    archived             = optional(bool, false)
    rule_bypassing_teams = set(string)
    environments = optional(list(object({
      name                    = string
      variables               = optional(map(string), {})
      require_review_by_teams = optional(set(string), [])
    })), [])
  }))
  description = "Repositories to be managed"

  validation {
    condition     = alltrue([for r in var.repositories : !(r.is_template && r.from_template != null)])
    error_message = "Repo cannot be both created from template and template itself"
  }

  validation {
    condition     = alltrue([for r in var.repositories : length(r.description) > 9])
    error_message = "For each repo, provide a meaningful description of at least 9 characters"
  }

  validation {
    condition     = alltrue([for r in var.repositories : length(r.name) > 0])
    error_message = "Repo name is required"
  }

  validation {
    condition     = alltrue([for r in var.repositories : contains(["private", "public"], r.visibility)])
    error_message = "Repo visibility should be either 'private' or 'public'"
  }

  validation {
    condition     = alltrue([for r in var.repositories : length(r.rule_bypassing_teams) > 0])
    error_message = "At least one team should be privileged to bypass branch protection rules"
  }
}
