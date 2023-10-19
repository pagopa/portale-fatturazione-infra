# general

variable "prefix" {
  type = string
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "env" {
  type = string
  validation {
    condition = (
      length(var.env) <= 4
    )
    error_message = "Max length is 4 chars."
  }
}

variable "env_short" {
  type = string
  validation {
    condition = (
      length(var.env_short) <= 1
    )
    error_message = "Max length is 1 chars."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "location_short" {
  type        = string
  description = "Location short like eg: neu, weu.."
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

#
# DNS
#

variable "dns_zone_portalefatturazione_prefix" {
  type        = string
  description = "DNS zone name"
}

variable "external_domain" {
  type        = string
  description = "DNS zone name"
  default     = "pagopa.it"
}

variable "dns_default_ttl_sec" {
  type        = number
  description = "DNS record Time To Live"
  default     = 3600
}