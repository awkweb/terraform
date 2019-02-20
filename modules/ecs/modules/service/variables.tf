variable "lb_target_group_arn" {
  description = "ARN of the ALB target group that should be associated with the ECS service"
}

variable "cluster_name" {
  description = "Name of the ECS cluster to create service in"
}

variable "container_name" {
  description = "Name of the container that will be attached to the ALB"
}

variable "container_port" {
  description = "port the container is listening on"
}

variable "desired_count" {
  description = "Desired count of the ECS task"
  default     = 1
}

variable "name" {
  description = "Name of the ecs service"
}

variable "security_groups_ids" {
  type = "list"
}

variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  default     = []
}
