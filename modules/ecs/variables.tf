variable "name" {}

variable "vpc_id" {}

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
