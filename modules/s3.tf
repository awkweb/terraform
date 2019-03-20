resource "aws_s3_bucket" "api_assets" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.api-assets"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "api" {
  bucket = "${aws_s3_bucket.api_assets.id}"
  policy = "${data.template_file.api_assets_origin.rendered}"
}

resource "aws_s3_bucket" "www" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.www"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "www" {
  bucket = "${aws_s3_bucket.www.id}"
  policy = "${data.template_file.www_origin.rendered}"
}

resource "aws_s3_bucket" "www_redirect" {
  acl           = "public-read"
  bucket        = "${var.name}.${var.env}.www-redirect"
  force_destroy = true

  website {
    redirect_all_requests_to = "https://${var.route53_zone}"
  }
}

resource "aws_s3_bucket_policy" "www_redirect" {
  bucket = "${aws_s3_bucket.www_redirect.id}"
  policy = "${data.template_file.www_redirect_origin.rendered}"
}
