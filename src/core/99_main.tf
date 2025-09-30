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
  # github.com/pagopa/terraform-azurerm-v4/releases/tag/v7.40.1
  source = "github.com/pagopa/terraform-azurerm-v4?ref=7d823b19688558110a50ea48359bbe1e6f5ef649"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
