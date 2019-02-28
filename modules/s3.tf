resource "aws_s3_bucket" "ecs" {
  bucket = "${var.name}.${var.env}.ecs"
}
