locals {
  dev = {
    subscription_id   = data.azurerm_subscriptions.dev.subscriptions[0].subscription_id
    subscription_name = var.dev_subscription_name
    # key_vault_name    = var.dev_key_vault_name
    # key_vault_rg_name = var.dev_key_vault_rg_name
    # dns_zone_rg_name  = var.dev_dns_zone_rg_name
  }
}

variable "dev_subscription_name" {
  type        = string
  description = "DEV Subscription name"
}

# variable "dev_key_vault_name" {
#   type        = string
#   description = "DEV Key Vault name"
# }

# variable "dev_key_vault_rg_name" {
#   type        = string
#   description = "DEV Key Vault resource group name"
# }

# variable "dev_dns_zone_rg_name" {
#   type        = string
#   description = "DEV DNS Zone resource group name"
# }
