resource "aws_s3_bucket" "api" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.api"
  force_destroy = true
}
