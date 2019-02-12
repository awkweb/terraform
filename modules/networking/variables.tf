variable "availability_zones" {
  type        = "list"
  description = "AZ resources will be launched"
}

variable "environment" {}

variable "key_name" {
  description = "Public key for bastion host"
}

variable "region" {
  description = "Region to launch bastion host"
}

variable "vpc_cidr" {
  description = "CIDR block of VPC"
}

variable "public_subnets_cidr" {
  type        = "list"
  description = "CIDR block for public subnet"
}

variable "private_subnets_cidr" {
  type        = "list"
  description = "CIDR block for private subnet"
}
