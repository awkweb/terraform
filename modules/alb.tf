resource "aws_alb" "instance" {
  name            = "${var.name}-${var.env}-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.public.*.id}"]
}

resource "aws_alb_target_group" "instance" {
  name     = "${var.name}-${var.env}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.instance.id}"

  health_check {
    path = "/v1/"
  }

  depends_on = ["aws_alb.instance"]
}

resource "aws_alb_listener" "port_80" {
  load_balancer_arn = "${aws_alb.instance.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = ["aws_alb_target_group.instance"]
}

resource "aws_alb_listener" "port_443" {
  load_balancer_arn = "${aws_alb.instance.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.instance.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.instance.arn}"
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.instance"]
}
