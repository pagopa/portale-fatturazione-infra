#
# general
#

variable "prefix" {
  type = string
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "max length is 6 chars."
  }
}

variable "env" {
  type = string
  validation {
    condition = (
      length(var.env) <= 4
    )
    error_message = "max length is 4 chars."
  }
}

variable "env_short" {
  type = string
  validation {
    condition = (
      length(var.env_short) <= 1
    )
    error_message = "max length is 1 chars."
  }
}

variable "location" {
  type    = string
  default = "italynorth"
}

variable "secondary_location" {
  type    = string
  default = "westeurope"
}

variable "location_short" {
  type        = string
  description = "location short like eg: neu, weu.."
  default     = "itn"
}

variable "secondary_location_short" {
  type        = string
  description = "location short like eg: neu, weu.."
  default     = "weu"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

#
# dns
#

variable "dns_zone_portalefatturazione_prefix" {
  type        = string
  description = "dns zone name"
}

variable "dns_external_domain" {
  type        = string
  description = "root dns zone name (external)"
  default     = "pagopa.it"
}

variable "dns_api_prefix" {
  type        = string
  description = "dns name of the api endpoint"
  default     = "api"
}

variable "dns_default_ttl_sec" {
  type        = number
  description = "dns ttl"
  default     = 3600
}

#
# networking
#

variable "cidr_vnet" {
  type        = list(string)
  description = "cidr of the vnet"
}

variable "cidr_agw_snet" {
  type        = list(string)
  description = "cidr of the appgateway subnet"
}

variable "cidr_app_snet" {
  type        = list(string)
  description = "cidr of the appservice subnet"
}

variable "cidr_synapse_snet" {
  type        = list(string)
  description = "cidr of the synapse subnet"
}

variable "cidr_hsql_snet" {
  type        = list(string)
  description = "cidr of the hyperscale sql subnet"
}

variable "cidr_pvt_endp_snet" {
  type        = list(string)
  description = "cidr of the private endpoints subnet"
}

variable "cidr_vpn_snet" {
  type        = list(string)
  description = "cidr of the vpn subnet"
}

variable "cidr_dns_fwd_snet" {
  type        = list(string)
  description = "cidr of the dns forwarder subnet"
}

#
# secondary networking
#

variable "secondary_cidr_vnet" {
  type        = list(string)
  description = "cidr of the secondary vnet"
}

variable "secondary_cidr_pvt_endp_snet" {
  type        = list(string)
  description = "cidr of the private endpoints subnet on secondary"
}


#
# appgateway
#
variable "agw_api_app_certificate_name" {
  type        = string
  description = "the certificate name on the kv for the api endpoint"
}

variable "agw_apex_app_certificate_name" {
  type        = string
  description = "the certificate name on the kv for the api endpoint"
}


#
# appservice
#
variable "app_plan_sku_name" {
  type        = string
  description = "the name of the app plan sku"
}

#
# kv
#
variable "adgroup_prefix" {
  type        = string
  description = "prefix of the ad group name"
}

variable "kv_soft_delete_retention_days" {
  type        = number
  description = "number of days before keys are removed (soft delete)"
  default     = 30
}

variable "kv_sku_name" {
  type        = string
  description = "name of the keyvault sku"
  default     = "standard"
}

#
# storage
#
variable "storage_delete_retention_days" {
  type        = number
  description = "blob and container retention days on (soft) delete"
  default     = 30
}

#
# azure sql
#
variable "sql_version" {
  type        = string
  description = "the required version of the sql server"
  default     = "12.0"
}

# variable "sql_database_max_size_gb" {
#   type        = number
#   description = "the max size in gb of the database"
#   default     = 250
# }

variable "sql_database_sku_name" {
  type        = string
  description = "the name of the database sku"
}

#
# synapse
#
variable "syn_spark_version" {
  type        = string
  description = "the required version of the spark cluster"
  default     = "3.3"
}

#
# log analytics workspace
#
variable "law_sku" {
  type        = string
  description = "the name of the log analytics workspace sku"
  default     = "PerGB2018"
}

variable "law_retention_in_days" {
  type        = number
  description = "retention in days of the log analytics workspace"
  default     = 30
}

variable "law_daily_quota_gb" {
  type        = number
  description = "daily quota in gb of the log analytics workspace (default: -1, unlimited)"
  default     = -1
}