#######################
# Required Variables
# DO NOT REMOVE
#######################
variable "Brand" {
  type        = string
  default     = "Audacy"
  description = "Brand that the service is responsible for."
}

variable "Team" {
  type        = string
  default     = "DevOps"
  description = "Name of the team that maintains the resource."
}

variable "Service" {
  type        = string
  default     = "Postgres"
  description = "Name of the resource (e.g. Elasticsearch)"
}

variable "account_id" {
  type = string
}

variable "token" {
  description = "Pagerduty API key"
  type        = string
}

#######################
# Resource Variables
#######################
