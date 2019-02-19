variable "availability_zones" {
  type = "list"
}

variable "environment" {}

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
