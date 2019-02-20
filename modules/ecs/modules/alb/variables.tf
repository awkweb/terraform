variable "certificate_arn" {
  description = "ARN for SSL/TLS certificate"
  default     = "cert_arn"
}

variable "name" {
  description = "Base name to use for resources in the module"
}

variable "security_groups_ids" {
  type = "list"
}

variable "vpc_id" {
  description = "VPC ID to create cluster in"
}

variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  default     = []
}
