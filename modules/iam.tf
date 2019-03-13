resource "aws_iam_role" "ec2" {
  name = "${var.name}-${var.env}-ec2-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ec2_container" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# TODO - CAN REMOVE
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-${var.env}-instance-profile"
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role" "ecs" {
  name = "${var.name}-${var.env}-ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
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

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role" "autoscale" {
  name = "${var.name}-${var.env}-ecs-autoscale-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_policy" {
  role       = "${aws_iam_role.autoscale.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

data "aws_iam_policy_document" "api_origin" {
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

data "aws_iam_policy_document" "web_origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.name}.${var.env}.web/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.api.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.name}.${var.env}.web"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.api.iam_arn}"]
    }
  }
}
