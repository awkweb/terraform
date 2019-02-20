/*========================================
Variables used across all modules
========================================*/
locals {
  region             = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

/*========================================
AWS provider
========================================*/
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${local.region}"
  version    = "1.59"
}

/*========================================
Modules
========================================*/
module "networking" {
  source      = "./modules/networking"
  name        = "${var.name}"
  environment = "${var.environment}"
  vpc_cidr    = "10.0.0.0/16"

  availability_zones   = "${local.availability_zones}"
  public_subnets_cidr  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

module "rds" {
  source      = "./modules/rds"
  name        = "${var.name}"
  environment = "${var.environment}"

  allocated_storage = "20"
  database_name     = "${var.database_name}"
  database_password = "${var.database_password}"
  database_username = "${var.database_username}"
  instance_class    = "db.t2.micro"

  subnet_ids = ["${module.networking.private_subnets_id}"]
  vpc_id     = "${module.networking.vpc_id}"
}

module "ecs" {
  source      = "./modules/ecs"
  name        = "${var.name}"
  environment = "${var.environment}"

  vpc_id             = "${module.networking.vpc_id}"
  availability_zones = "${local.availability_zones}"
  subnets_ids        = ["${module.networking.private_subnets_id}"]
  public_subnet_ids  = ["${module.networking.public_subnets_id}"]

  security_groups_ids = [
    "${module.networking.security_groups_ids}",
    "${module.rds.db_access_sg_id}",
  ]

  database_endpoint   = "${module.rds.rds_address}"
  database_name       = "${var.database_name}"
  database_username   = "${var.database_username}"
  database_password   = "${var.database_password}"
  ssl_certificate     = "${var.ssl_certificate}"
  ssl_certificate_key = "${var.ssl_certificate_key}"
}
