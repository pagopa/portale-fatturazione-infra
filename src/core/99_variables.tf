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

variable "dns_default_ttl_sec" {
  type        = number
  description = "dns ttl"
  default     = 3600
}


#
# appgateway
#

variable "agw_sku" {
  type        = string
  description = "sku of the app gateway"
}

variable "agw_waf_enabled" {
  type        = bool
  description = "whether to enable WAF on the app gateway"
}

variable "agw_autoscale" {
  type        = bool
  description = "whether to autoscale app gateway"
  default     = true
}


#
# appservice
#
variable "app_plan_sku_name" {
  type        = string
  description = "the name of the app plan sku"
}

variable "app_plan_zone_balancing_enabled" {
  type        = bool
  description = "enable zone balancing on app service"
  default     = true
}

variable "app_staging_slot_enabled" {
  type        = bool
  description = "enable staging slot in app service"
  default     = true
}

variable "app_api_config_selfcare_url" {
  type        = string
  description = "the url of the selfcare service"
  default     = "https://selfcare.pagopa.it"
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

variable "storage_sa_rule_ips" {
  type        = list(string)
  description = "ips used in the sa storage account network rules"
  default     = []
}

variable "storage_sap_rule_ips" {
  type        = list(string)
  description = "ips used in the sap storage account network rules"
  default     = []
}

variable "storage_dls_rule_ips" {
  type        = list(string)
  description = "ips used in the dls storage account network rules"
  default     = []
}

# this storage is in another subscription, we reference it directly by id
variable "crm_storage_id" {
  type        = string
  description = "id of the CRM storage, that lies in another subscription"
  default     = null
}

#
# azure sql
#
variable "sql_version" {
  type        = string
  description = "the required version of the sql server"
  default     = "12.0"
}

variable "sql_database_max_size_gb" {
  type        = number
  description = "the max size in gb of the database"
  default     = 250
}

variable "sql_database_sku_name" {
  type        = string
  description = "the name of the database sku"
}

variable "sql_database_read_scale" {
  type        = bool
  description = "enable sql database read only ha replica"
  default     = false
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

#
# alerts
#
variable "alert_sdi_code_enabled" {
  type        = bool
  description = "Feature flag for SDI code modification notification alert"
  default     = true
}
variable "alert_sdi_code_frequency_mins" {
  type        = number
  description = "the frequency of evaluation of the query for the SDI code modification alert"
  default     = 10
}

variable "alert_sdi_code_time_window_mins" {
  type        = number
  description = "the time window of the query for the SDI code modification alert"
  default     = 11
}

#
# feature flags
#
variable "function_app_integration_enabled" {
  type        = bool
  description = "Feature flag for integration function app"
  default     = false
}

variable "grafana_enabled" {
  type        = bool
  description = "Feature flag for grafana"
  default     = true
}

#
# integrations
#
variable "send_api_url" {
  type        = string
  description = "Base URL of the SEND API"
}

