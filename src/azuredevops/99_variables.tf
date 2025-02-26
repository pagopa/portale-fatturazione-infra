locals {
  github_readonly_token_name  = "azure-devops-github-ro-TOKEN"
  github_readwrite_token_name = "azure-devops-github-rw-TOKEN"
  project                     = "${var.prefix}-${var.env_short}"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  subscription_id             = data.azurerm_subscription.current.subscription_id
  subscription_name           = data.azurerm_subscription.current.display_name
}

variable "prefix" {
  type = string
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "env_short" {
  type = string
  validation {
    condition = (
      length(var.env_short) <= 1
    )
    error_message = "max length is 1 chars."
  }
}

variable "location" {
  type = string
}

variable "project_name_prefix" {
  type        = string
  description = "Prefix of the azure devops project"
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name"
}

variable "key_vault_rg_name" {
  type        = string
  description = "Key Vault resource group name"
}

variable "dns_zone_rg_name" {
  type        = string
  description = "DNS zones resource group name"
}

variable "identity_rg_name" {
  type        = string
  description = "Identities resource group name"
}

variable "domains" {
  type = list(object({
    dns_zone_name   = string
    dns_record_name = string
  }))
  description = "Domains to manage regarding TLS certifcates"
}

variable "le_acme_tiny_repository" {
  type = object({
    organization   = string
    name           = string
    branch_name    = string
    pipelines_path = string
  })
  description = "Repository of the Let's Encrypt ACME script"
  default = {
    organization   = "pagopa"
    name           = "le-azure-acme-tiny"
    branch_name    = "refs/heads/master"
    pipelines_path = "."
  }
}

variable "cert_expire_seconds" {
  type        = number
  default     = 2592000
  description = "Renew certificate if it expires in this interval. Defaults to 30 days"
}

variable "repos_to_sync" {
  description = "Repositories to sync to GitHub"
  type = list(object({
    organization = string
    name         = string
    branch_name  = string
    yml_path     = string
  }))
  default = []
}
