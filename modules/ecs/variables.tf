variable "name" {}

variable "environment" {}

variable "vpc_id" {}

variable "availability_zones" {
  type = "list"
}

variable "security_groups_ids" {
  type = "list"
}

variable "subnets_ids" {
  type        = "list"
  description = "Private subnets to use"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "Public subnets to use"
}

variable "database_endpoint" {}

variable "database_username" {}

variable "database_password" {}

variable "database_name" {}

variable "ssl_certificate" {}

variable "ssl_certificate_key" {}
