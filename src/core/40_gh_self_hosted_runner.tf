
variable "self_hosted_runner_github_repos" {
  type = list(object({
    name                 = optional(string)
    repo_owner           = optional(string)
    repo                 = optional(string)
    polling_interval     = optional(number)
    scale_max_executions = optional(number)
  }))

  default = [
    {
      name                 = "pf-be" // portale-fatturazione-be will make the job name exceed 32 chars
      repo_owner           = "pagopa"
      repo                 = "portale-fatturazione-be"
      polling_interval     = 30
      scale_max_executions = 5
    },
  ]

  description = "Container App job properties for GitHub self-hosted runners"
}

locals {
  gh_runner = {
    rg_name          = "${local.project}-github-runner-rg"
    law_name         = "${local.project}-runner-law"
    environment_name = "${local.project}-runner-cae"
  }
}

resource "azurerm_resource_group" "runner_rg" {
  name     = local.gh_runner.rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "runner_law" {
  name                = local.gh_runner.law_name
  location            = azurerm_resource_group.runner_rg.location
  resource_group_name = azurerm_resource_group.runner_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

module "github_runner_snet" {
  source                                    = "./.terraform/modules/__v3__/subnet/"
  name                                      = format("%s-%s-snet", local.project, "github-runner")
  address_prefixes                          = var.cidr_github_runner_snet
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = module.vnet.name
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = []
}

resource "azurerm_container_app_environment" "runner_cae" {
  name                           = local.gh_runner.environment_name
  resource_group_name            = azurerm_resource_group.runner_rg.name
  location                       = azurerm_resource_group.runner_rg.location
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.runner_law.id
  infrastructure_subnet_id       = module.github_runner_snet.id
  internal_load_balancer_enabled = true

  tags = var.tags
}

module "container_app_job_runner" {
  for_each = { for job in var.self_hosted_runner_github_repos : job.name => job }
  source   = "./.terraform/modules/__v3__8_28_2__/container_app_job_gh_runner/"

  location  = var.location
  prefix    = var.prefix
  env_short = var.env_short

  # sets reference to the secret which holds the GitHub PAT with access to your repos
  key_vault = {
    resource_group_name = module.key_vault.resource_group_name
    name                = module.key_vault.name
    secret_name         = "github-runner-bot-cicd"
  }

  # sets reference to the log analytics workspace you want to use for logging
  environment = {
    name                = azurerm_container_app_environment.runner_cae.name
    resource_group_name = azurerm_container_app_environment.runner_cae.resource_group_name
  }

  # sets job properties
  job = each.value

  tags = var.tags
}
