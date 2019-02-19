/*====
Cloudwatch Log Group
======*/
resource "aws_cloudwatch_log_group" "wilbur" {
  name = "wilbur"

  tags {
    Environment = "${var.environment}"
    Application = "Wilbur"
  }
}

/*====
ECR repositories
======*/
resource "aws_ecr_repository" "nginx" {
  name = "nginx"
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = "${aws_ecr_repository.nginx.name}"
  policy     = "${file("${path.module}/policies/ecr-lifecycle-policy.json")}"
}

/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-ecs-cluster"
}

/*====
Launch Configuration & Auto Scaling Group
from https://blog.ulysse.io/post/setting-up-ecs-with-terraform/
======*/
data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = "${aws_iam_role.docker_cluster_instance_role.name}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/data/user_data.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_launch_configuration" "instance" {
  name                 = "${var.environment}"
  image_id             = "${data.aws_ami.ecs_optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_agent.name}"
  security_groups      = ["${var.security_groups_ids}"]
  user_data            = "${data.template_file.user_data.rendered}"
  key_name             = "${var.key_name}"

  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${var.environment}"
  vpc_zone_identifier  = ["${var.subnets_ids}"]
  launch_configuration = "${aws_launch_configration.instance.name}"

  desired_capacity = 3
  min_size         = 3
  max_size         = 3
}
