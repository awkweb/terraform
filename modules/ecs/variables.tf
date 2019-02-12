variable "environment" {}

variable "vpc_id" {
  description = "VPC id"
}

variable "availability_zones" {
  type        = "list"
  description = "AZs to use"
}

variable "security_groups_ids" {
  type        = "list"
  description = "SGs to use"
}

variable "subnets_ids" {
  type        = "list"
  description = "Private subnets to use"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "Private subnets to use"
}

variable "database_host" {
  description = "Database host"
}

variable "database_username" {
  description = "Database username"
}

variable "database_password" {
  description = "Database password"
}

variable "database_name" {
  description = "Database app will use"
}

variable "django_secret_key" {
  description = "Django secret key"
}

variable "plaid_client_id" {}

variable "plaid_public_key" {}

variable "plaid_secret" {}

variable "plaid_env" {}
