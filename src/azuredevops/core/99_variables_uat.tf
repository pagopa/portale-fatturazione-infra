locals {
  uat = {
    subscription_id   = data.azurerm_subscriptions.uat.subscriptions[0].subscription_id
    subscription_name = var.uat_subscription_name
    key_vault_name    = var.uat_key_vault_name
    key_vault_rg_name = var.uat_key_vault_rg_name
    dns_zone_rg_name  = var.uat_dns_zone_rg_name
    identity_rg_name  = var.uat_identity_rg_name
  }
}

variable "uat_subscription_name" {
  type        = string
  description = "UAT Subscription name"
}

variable "uat_key_vault_name" {
  type        = string
  description = "UAT Key Vault name"
}

variable "uat_key_vault_rg_name" {
  type        = string
  description = "UAT Key Vault resource group name"
}

variable "uat_dns_zone_rg_name" {
  type        = string
  description = "UAT DNS Zone resource group name"
}

variable "uat_identity_rg_name" {
  type        = string
  description = "UAT Managed Identity resource group name"
}
