terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
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

module "__v4__" {
  # github.com/pagopa/terraform-azurerm-v4/releases/tag/v1.9.0
  source = "github.com/pagopa/terraform-azurerm-v4?ref=d9aee53bcf1d1e01594cc3276447afe0635d1789"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
