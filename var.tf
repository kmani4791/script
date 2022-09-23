variable "ES_DOMAIN_NAME" {
  description = "Name of Elasticsearch domain"
  type        = string
  default     = null
}

variable "ES_MASTER_NAME" {
  description = "Name for ES master internal account"
  type        = string
  default     = null
}

variable "ES_MASTER_PASSWORD" {
  description = "Password for ES master internal account"
  type        = string
  default     = null
}

variable "VPC_NAME" {
  description = "VPC Name"
  type        = string
  default     = null
}

variable "VPC_SUBNETS" {
  description = "VPC Name"
  type        = list(string)
  default     = null
}

