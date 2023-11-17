terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.76.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "<= 2.43.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

module "v3" {
  # https://github.com/pagopa/terraform-azurerm-v3/releases/tag/v7.23.0
  source = "git::github.com/pagopa/terraform-azurerm-v3.git?ref=d97d51148b02eb3225507eeef2ec25d52f4f343b"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
