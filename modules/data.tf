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

data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  owners = ["amazon"]
}

data "aws_iam_policy_document" "origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.name}.${var.env}.api/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.api.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.name}.${var.env}.api"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.api.iam_arn}"]
    }
  }
}

data "aws_ecr_repository" "api" {
  name = "${var.name}-${var.env}/api"
}

data "aws_ecr_repository" "nginx" {
  name = "${var.name}-${var.env}/nginx"
}

data "aws_route53_zone" "instance" {
  name = "wilbur.app."
}

data "external" "api_image" {
  program = ["bash", "scripts/ecr-get-tag-for-image.sh"]

  query = {
    repository_name = "${data.aws_ecr_repository.api.name}"
  }
}

data "external" "nginx_image" {
  program = ["bash", "scripts/ecr-get-tag-for-image.sh"]

  query = {
    repository_name = "${data.aws_ecr_repository.nginx.name}"
  }
}

data "template_file" "api_container_definition" {
  template = "${file("files/task-definitions/api.json")}"

  vars {
    api_image   = "${data.aws_ecr_repository.api.repository_url}:${data.external.api_image.result["tag"]}"
    nginx_image = "${data.aws_ecr_repository.nginx.repository_url}:${data.external.nginx_image.result["tag"]}"

    database_host     = "${aws_db_instance.instance.address}"
    database_name     = "${var.database_name}"
    database_password = "${var.database_password}"
    database_username = "${var.database_username}"
    django_env        = "${var.django_env}"
    django_secret_key = "${var.django_secret_key}"
    django_static_url = "https://${aws_cloudfront_distribution.api.domain_name}/"
    log_group         = "${aws_cloudwatch_log_group.instance.name}"
    plaid_client_id   = "${var.plaid_client_id}"
    plaid_env         = "${var.plaid_env}"
    plaid_public_key  = "${var.plaid_public_key}"
    plaid_secret      = "${var.plaid_secret}"
    region            = "${var.region}"
  }
}

data "template_file" "db_migrate_container_definition" {
  template = "${file("files/task-definitions/db_migrate.json")}"

  vars {
    api_image = "${data.aws_ecr_repository.api.repository_url}:${data.external.api_image.result["tag"]}"

    database_host     = "${aws_db_instance.instance.address}"
    database_name     = "${var.database_name}"
    database_password = "${var.database_password}"
    database_username = "${var.database_username}"
    django_env        = "${var.django_env}"
    django_secret_key = "${var.django_secret_key}"
    django_static_url = "https://${aws_cloudfront_distribution.api.domain_name}/"
    log_group         = "${aws_cloudwatch_log_group.instance.name}"
    plaid_client_id   = "${var.plaid_client_id}"
    plaid_env         = "${var.plaid_env}"
    plaid_public_key  = "${var.plaid_public_key}"
    plaid_secret      = "${var.plaid_secret}"
    region            = "${var.region}"
  }
}

data "template_file" "user_data_bastion" {
  template = "${file("files/user-data/bastion.sh")}"
}

data "template_file" "user_data_ecs" {
  template = "${file("files/user-data/ecs.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.instance.name}"
  }
}
