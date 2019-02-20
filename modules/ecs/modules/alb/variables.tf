variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

variable "backend_sg_id" {
  description = "Security group ID of the instance to add rule to allow incoming tcp from ALB"
}

variable "certificate_arn" {
  description = "ARN for SSL/TLS certificate"
  default     = "cert_arn"
}

variable "name" {
  description = "Base name to use for resources in the module"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID to create cluster in"
}

variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  default     = []
}
