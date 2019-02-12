variable "environment" {}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet ids"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "allocated_storage" {
  default     = "20"
  description = "Storage size in GB"
}

variable "instance_class" {
  description = "Instance type"
}

variable "multi_az" {
  default     = false
  description = "Muti-az allowed?"
}

variable "database_name" {}
variable "database_username" {}
variable "database_password" {}
