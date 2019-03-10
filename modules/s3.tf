resource "aws_s3_bucket" "api" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.api"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "api" {
  bucket = "${aws_s3_bucket.api.id}"
  policy = "${data.aws_iam_policy_document.origin.json}"
}
