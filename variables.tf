variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "cloudflare_email" {}

variable "cloudflare_token" {}

variable "database_name" {}

variable "database_password" {}

variable "database_username" {}

variable "django_env" {}

variable "django_secret_key" {}

variable "env" {
  default = "prod"
}

variable "name" {
  default = "butter"
}

variable "plaid_client_id" {}

variable "plaid_env" {}

variable "plaid_public_key" {}

variable "plaid_secret" {}

variable "region" {
  default = "us-east-1"
}
