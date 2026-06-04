# generic

variable "name" {
  type        = string
  description = "Name of the web app"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Tags of azure resources"
  default     = {}
}

# networking

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the web app"
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "Optional subnet id for virtual network integration"
  default     = null
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Optional subnet id where to put private endpoint"
  default     = null
}

variable "private_link_dns_zone_ids" {
  type        = list(string)
  description = "List of private DNS zone IDs to associate with private endpoints"
  default     = []
}

# app insights

variable "appinsights_instrumentation_key" {
  type        = string
  description = "Application Insights instrumentation key"
}

variable "appinsights_connection_string" {
  type        = string
  description = "Application Insights connection string"
}

# appservice

variable "app_port" {
  type        = number
  description = "Port the container listens on (EXPOSE in the Dockerfile), mapped to WEBSITES_PORT"
}

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service plan"
}

variable "client_affinity_enabled" {
  type        = bool
  description = "Client affinity enable"
  default     = false
}

variable "always_on" {
  type        = bool
  description = "Keep the app loaded even when there's no traffic. Must be true for Premium/Standard plans"
  default     = true
}

variable "custom_app_settings" {
  type        = map(string)
  description = "Custom app settings. DO NOT PUT APP INSIGHTS GARBAGE HERE"
  default     = {}
}

variable "sticky_app_setting_names" {
  type        = list(string)
  description = "List of names of app settings that are local to slots"
  default     = []
}

variable "health_check_path" {
  type        = string
  description = "Path to ping as health check"

}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "CORS allowed origin with schema http:// or https://"
  default     = []
}

variable "cors_support_credentials" {
  type        = bool
  description = "CORS allow credentials (Access-Control-Allow-Credentials: true)"
  default     = false
}

variable "app_staging_slot_enabled" {
  type        = bool
  description = "Staging slot enabled"
  default     = false
}
