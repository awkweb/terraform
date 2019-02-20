resource "aws_security_group" "instance" {
  name   = "${var.name}-inbound-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "instance" {
  name            = "${var.name}-alb"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${var.security_groups_ids}", "${aws_security_group.instance.id}"]
}

resource "aws_alb_target_group" "instance" {
  name = "${var.name}-alb-target-group"

  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  # target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
  depends_on = ["aws_alb.instance"]
}

resource "aws_alb_listener" "instance" {
  load_balancer_arn = "${aws_alb.instance.arn}"
  port              = "443"
  protocol          = "HTTPS"

  certificate_arn = "${var.certificate_arn}"

  depends_on = ["aws_alb_target_group.instance"]

  default_action {
    target_group_arn = "${aws_alb_target_group.instance.arn}"
    type             = "forward"
  }
}
