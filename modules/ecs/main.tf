/*========================================
ECS cluster & alb
========================================*/
module "ecs_cluster" {
  source = "./modules/cluster"

  name                = "${var.name}-${var.environment}"
  security_groups_ids = ["${var.security_groups_ids}"]
  vpc_id              = "${var.vpc_id}"
  vpc_subnets         = ["${var.subnets_ids}"]

  tags = {
    Environment = "${var.environment}"
    Application = "${var.name}"
  }
}

module "alb" {
  source = "./modules/alb"

  name            = "${var.name}-${var.environment}"
  certificate_arn = "arn:aws:acm:us-east-1:102953801091:certificate/fc732d70-d39a-43e5-97c4-3438b2ed9c47"
  backend_sg_id   = "${module.ecs_cluster.instance_sg_id}"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.name}"
  }

  vpc_id      = "${var.vpc_id}"
  vpc_subnets = ["${var.public_subnet_ids}"]
}

/*========================================
ECS task definition & service
========================================*/
resource "aws_ecs_task_definition" "app" {
  family = "${var.name}-${var.environment}"

  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:1.13-alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "app-dev-nginx",
        "awslogs-region": "us-east-1"
      }
    },
    "memory": 128,
    "cpu": 100
  }
]
EOF
}

module "ecs_service_app" {
  source = "./modules/service"

  name                 = "${var.name}-${var.environment}"
  alb_target_group_arn = "${module.alb.target_group_arn}"
  cluster              = "${module.ecs_cluster.cluster_id}"
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["${var.name}-${var.environment}-nginx"]
  task_definition_arn  = "${aws_ecs_task_definition.app.arn}"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.name}"
  }
}
