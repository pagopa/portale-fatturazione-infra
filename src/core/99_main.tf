terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # last available version of azurerm v3
      # upgrade to v4 will break all modules
      version = "= 3.117.0"
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
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

module "__v3__" {
  # https://github.com/pagopa/terraform-azurerm-v3/releases/tag/v8.71.0
  source = "github.com/pagopa/terraform-azurerm-v3?ref=8e1de5c01dfb551c2a99998ed65efc2d34102a78"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
