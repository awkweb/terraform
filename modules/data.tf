data "aws_acm_certificate" "instance" {
  domain = "${var.route53_zone}"
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
    resources = ["$${s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["$${cloudfront_iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["$${s3_bucket_arn}"]

    principals {
      type        = "AWS"
      identifiers = ["$${cloudfront_iam_arn}"]
    }
  }
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
    django_static_url = "https://api-assets.${var.route53_zone}/"
    log_group         = "${aws_cloudwatch_log_group.instance.name}"
    plaid_client_id   = "${var.plaid_client_id}"
    plaid_env         = "${var.plaid_env}"
    plaid_public_key  = "${var.plaid_public_key}"
    plaid_secret      = "${var.plaid_secret}"
    region            = "${var.region}"
  }

  depends_on = ["aws_route53_record.api_assets"]
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
    django_static_url = "https://api-assets.${var.route53_zone}/"
    log_group         = "${aws_cloudwatch_log_group.instance.name}"
    plaid_client_id   = "${var.plaid_client_id}"
    plaid_env         = "${var.plaid_env}"
    plaid_public_key  = "${var.plaid_public_key}"
    plaid_secret      = "${var.plaid_secret}"
    region            = "${var.region}"
  }

  depends_on = ["aws_route53_record.api_assets"]
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

data "template_file" "api_assets_origin" {
  template = "${data.aws_iam_policy_document.origin.json}"

  vars {
    cloudfront_iam_arn = "${aws_cloudfront_origin_access_identity.api_assets.iam_arn}"
    s3_bucket_arn      = "${aws_s3_bucket.api_assets.arn}"
  }
}

data "template_file" "www_origin" {
  template = "${data.aws_iam_policy_document.origin.json}"

  vars {
    cloudfront_iam_arn = "${aws_cloudfront_origin_access_identity.www.iam_arn}"
    s3_bucket_arn      = "${aws_s3_bucket.www.arn}"
  }
}

data "template_file" "www_redirect_origin" {
  template = "${data.aws_iam_policy_document.origin.json}"

  vars {
    cloudfront_iam_arn = "${aws_cloudfront_origin_access_identity.www_redirect.iam_arn}"
    s3_bucket_arn      = "${aws_s3_bucket.www_redirect.arn}"
  }
}
