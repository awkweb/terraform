/*========================================
ECS cluster & alb
========================================*/
module "alb" {
  source = "./modules/alb"

  certificate_arn     = "arn:aws:acm:us-east-1:102953801091:certificate/fc732d70-d39a-43e5-97c4-3438b2ed9c47"
  name                = "${var.name}"
  security_groups_ids = ["${var.security_groups_ids}"]
  vpc_id              = "${var.vpc_id}"
  vpc_subnets         = ["${var.public_subnet_ids}"]
}

module "ecs_cluster" {
  source = "./modules/cluster"

  name = "${var.name}"

  // TODO - remove lb_security_group_id?
  security_groups_ids = ["${var.security_groups_ids}", "${module.alb.lb_security_group_id}"]
  vpc_id              = "${var.vpc_id}"
  vpc_subnets         = ["${var.subnets_ids}"]
}

module "ecs_service" {
  source = "./modules/service"

  name                = "${var.name}"
  lb_target_group_arn = "${module.alb.lb_target_group_arn}"
  cluster_name        = "${module.ecs_cluster.cluster_name}"
  container_name      = "nginx"
  container_port      = "80"
  desired_count       = 1

  security_groups_ids = ["${var.security_groups_ids}", "${module.alb.lb_security_group_id}"]
  vpc_subnets         = ["${var.subnets_ids}"]
}
