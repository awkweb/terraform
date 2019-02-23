data "aws_acm_certificate" "instance" {
  domain = "*.wilbur.app"
}

data "aws_ecr_repository" "api" {
  name = "${var.name}-${var.env}/api"
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
    /* api_image         = "${data.aws_ecr_repository.api.repository_url}" */
    api_image         = "102953801091.dkr.ecr.us-east-1.amazonaws.com/wilbur-prod/api:0aade9ec0a0a02f4e248502483894e48fc1c8889"
    database_host     = "${aws_db_instance.instance.address}"
    database_name     = "${var.database_name}"
    database_password = "${var.database_password}"
    database_username = "${var.database_username}"
    django_env        = "${var.django_env}"
    django_secret_key = "${var.django_secret_key}"
    log_group         = "${aws_cloudwatch_log_group.instance.name}"
    plaid_client_id   = "${var.plaid_client_id}"
    plaid_env         = "${var.plaid_env}"
    plaid_public_key  = "${var.plaid_public_key}"
    plaid_secret      = "${var.plaid_secret}"
    region            = "${var.region}"
  }
}

data "template_file" "nginx_conf" {
  template = "${file("files/nginx.conf")}"
}

data "template_file" "user_data" {
  template = "${file("files/user_data.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.instance.name}"
    env         = "${var.env}"
    name        = "${var.name}"
    region      = "${var.region}"
  }
}
