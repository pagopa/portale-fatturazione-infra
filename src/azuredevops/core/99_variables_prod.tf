locals {
  prod = {
    subscription_id   = data.azurerm_subscriptions.prod.subscriptions[0].subscription_id
    subscription_name = var.prod_subscription_name
    key_vault_name    = var.prod_key_vault_name
    key_vault_rg_name = var.prod_key_vault_rg_name
    dns_zone_rg_name  = var.prod_dns_zone_rg_name
    identity_rg_name  = var.prod_identity_rg_name
  }
}

variable "prod_subscription_name" {
  type        = string
  description = "PROD Subscription name"
}

variable "prod_key_vault_name" {
  type        = string
  description = "PROD Key Vault name"
}

variable "prod_key_vault_rg_name" {
  type        = string
  description = "PROD Key Vault resource group name"
}

variable "prod_dns_zone_rg_name" {
  type        = string
  description = "PROD DNS Zone resource group name"
}

variable "prod_identity_rg_name" {
  type        = string
  description = "PROD Managed Identity resource group name"
}
