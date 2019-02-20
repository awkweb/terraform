resource "aws_cloudwatch_log_group" "instance" {
  name = "wilbur"
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "template_file" "task" {
  template = "${file("${path.module}/task_definition.json")}"

  vars {
    log_group = "${aws_cloudwatch_log_group.instance.name}"
  }
}

resource "aws_ecs_task_definition" "instance" {
  family                = "${var.name}"
  container_definitions = "${data.template_file.task.rendered}"

  # network_mode          = "awsvpc"
  cpu    = "256"
  memory = "512"
}

resource "aws_ecs_service" "instance" {
  name            = "${var.name}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.instance.family}:${aws_ecs_task_definition.instance.revision}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.ecs_service_role.name}"

  # network_configuration {
  #   security_groups = ["${var.security_groups_ids}"]
  #   subnets         = ["${var.vpc_subnets}"]
  # }

  load_balancer {
    target_group_arn = "${var.lb_target_group_arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}
