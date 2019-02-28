provider "template" {
  version = "2.0"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
  version    = "1.59"
}

module "app" {
  source = "./modules"

  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  django_env        = "${var.django_env}"
  django_secret_key = "${var.django_secret_key}"
  plaid_client_id   = "${var.plaid_client_id}"
  plaid_public_key  = "${var.plaid_public_key}"
  plaid_secret      = "${var.plaid_secret}"
  plaid_env         = "${var.plaid_env}"
}
