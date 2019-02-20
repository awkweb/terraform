variable "asg_max_size" {
  description = "Maximum number EC2 instances"
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum number of instances"
  default     = 1
}

variable "asg_desired_size" {
  description = "Desired number of instances"
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type (default=t2.micro)"
  default     = "t2.micro"
}

variable "name" {
  description = "Base name to use for resources in the module"
}

variable "security_groups_ids" {
  type = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID to create cluster in"
}

variable "vpc_subnets" {
  description = "List of VPC subnets to put instances in"
  default     = []
}
