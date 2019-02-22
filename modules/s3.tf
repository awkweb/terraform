resource "aws_s3_bucket" "ecs" {
  bucket = "${var.name}.${var.env}.ecs"
}

resource "aws_s3_bucket_object" "nginx_conf" {
  bucket  = "${aws_s3_bucket.ecs.id}"
  key     = "nginx.conf"
  content = "${data.template_file.nginx_conf.rendered}"
}
