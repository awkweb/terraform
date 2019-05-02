provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
  version    = "1.59"
}

provider "cloudflare" {
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
  version = "1.12.0"
}

provider "external" {
  version = "1.1"
}

provider "template" {
  version = "2.0"
}

module "app" {
  source = "./modules"

  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  django_env        = "${var.django_env}"
  django_secret_key = "${var.django_secret_key}"
  env               = "${var.env}"
  name              = "${var.name}"
  plaid_client_id   = "${var.plaid_client_id}"
  plaid_public_key  = "${var.plaid_public_key}"
  plaid_secret      = "${var.plaid_secret}"
  plaid_env         = "${var.plaid_env}"
  region            = "${var.region}"
}
