provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
  version    = "1.59"
}

module "app" {
  source          = "./modules"
  certificate_arn = "${var.certificate_arn}"
}
