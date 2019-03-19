resource "aws_s3_bucket" "api" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.api"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "api" {
  bucket = "${aws_s3_bucket.api.id}"
  policy = "${data.aws_iam_policy_document.api_origin.json}"
}

resource "aws_s3_bucket" "web" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.web"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "web" {
  bucket = "${aws_s3_bucket.web.id}"
  policy = "${data.aws_iam_policy_document.web_origin.json}"
}

resource "aws_s3_bucket" "web_redirect" {
  acl           = "public-read"
  bucket        = "${var.name}.${var.env}.web-redirect"
  force_destroy = true

  website {
    redirect_all_requests_to = "https://${var.route53_zone}"
  }
}
