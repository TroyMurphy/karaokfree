variable "tenant_id" {
  description = "Tenant Id"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "keyvault_name" {
  description = "Name of the key vault resource"
  type        = string
  default     = "karafree-keyvault"
}

variable "service_plan_name" {
  description = "Name of the web pub sub resource"
  type        = string
  default     = "karafree-sp"
}

variable "web_pubsub_name" {
  description = "Name of the web pub sub resource"
  type        = string
  default     = "webpubsub"
}

variable "web_app_name" {
  description = "Name of the web app backend api resource"
  type        = string
  default     = "webapi"
}

variable "web_application_insights_name" {
  description = "Name of the app insights resource"
  type        = string
  default     = "webai"
}
