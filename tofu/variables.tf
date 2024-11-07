variable "eventbus_name" {
  description = "Name of the EventBridge bus to monitor. Defaults to 'default'."
  type        = string
  default     = "default"
}


variable "retention_days" {
  description = "Retention period for the CloudWatch Logs group."
  type        = number
  default     = 1
}

variable "region" {
  description = "Region for deploying the resources into"
  type        = string
}

variable "tags" {
  type    = map(any)
  default = {}
}
