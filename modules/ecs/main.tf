/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-ecs-cluster"
}

/* Security Group for ECS */
resource "aws_security_group" "ecs_service" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.environment}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-ecs-service-sg"
    Environment = "${var.environment}"
  }
}

/*====
ECS Services
======*/
module "nginx" {
  source                    = "./services/nginx"
  environment               = "production"
  cluster_name              = "${aws_ecs_cluster.cluster.name}"
  cluster_id                = "${aws_ecs_cluster.cluster.id}"
  cluster_security_group_id = "${aws_security_group.ecs_service.id}"
  repository_name           = "nginx"

  public_subnet_ids   = "${var.public_subnet_ids}"
  security_groups_ids = "${var.security_groups_ids}"
  ssl_certificate     = "${var.ssl_certificate}"
  ssl_certificate_key = "${var.ssl_certificate_key}"
  subnets_ids         = "${var.subnets_ids}"
  vpc_id              = "${var.vpc_id}"
}
