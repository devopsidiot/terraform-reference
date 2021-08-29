variable "Brand" {
  type        = string
  default     = ""
  description = "Brand that the service is responsible for."
}

variable "Team" {
  type        = string
  default     = "DevOps"
  description = "Name of the team that maintains the resource."
}

variable "Service" {
  type        = string
  default     = "EKS-prod"
  description = "Name of the resource (e.g. EKS)"
}

variable "account_id" {
  type = string
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Name of the cluster"
}

variable "token" {
  description = "Pagerduty API key"
  type        = string
}
