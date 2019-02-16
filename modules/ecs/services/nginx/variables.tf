variable "environment" {}

variable "cluster_name" {}

variable "cluster_id" {}

variable "cluster_security_group_id" {}

variable "public_subnet_ids" {
  type = "list"
}

variable "repository_name" {}

variable "security_groups_ids" {
  type = "list"
}

variable "ssl_certificate" {}

variable "ssl_certificate_key" {}

variable "subnets_ids" {
  type = "list"
}

variable "vpc_id" {}
