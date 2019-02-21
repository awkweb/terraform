data "aws_acm_certificate" "instance" {
  domain = "*.wilbur.app"
}

data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

data "aws_route53_zone" "instance" {
  name = "wilbur.app."
}

data "template_file" "api_container_definition" {
  template = "${file("files/task-definitions/api.json")}"

  vars {
    database_url = "postgresql://${var.database_username}:${var.database_password}@${aws_db_instance.instance.address}:5432/${var.database_name}?encoding=utf8&pool=40"
    log_group    = "${aws_cloudwatch_log_group.instance.name}"
  }
}

data "template_file" "user_data" {
  template = "${file("files/user_data.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.instance.name}"
  }
}
