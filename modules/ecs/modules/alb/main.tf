resource "aws_security_group_rule" "instance_in_alb" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = "${module.alb_sg_https.this_security_group_id}"
  security_group_id        = "${var.backend_sg_id}"
}

module "alb_sg_https" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.14.0"

  name   = "${var.name}-alb"
  vpc_id = "${var.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = "${var.tags}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name = "${var.name}"
  security_groups    = ["${module.alb_sg_https.this_security_group_id}"]

  http_tcp_listeners       = "${list(map("port", "${var.backend_port}", "protocol", "${var.backend_protocol}"))}"
  http_tcp_listeners_count = "1"
  https_listeners          = "${list(map("certificate_arn", "${var.certificate_arn}", "port", 443))}"
  https_listeners_count    = "1"

  logging_enabled = false

  subnets             = ["${var.vpc_subnets}"]
  tags                = "${var.tags}"
  target_groups       = "${list(map("name", "${var.name}", "backend_protocol", "${var.backend_protocol}", "backend_port", "${var.backend_port}"))}"
  target_groups_count = "1"
  vpc_id              = "${var.vpc_id}"
}
