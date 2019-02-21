resource "aws_route53_record" "api" {
  zone_id = "${data.aws_route53_zone.instance.zone_id}"
  name    = "api.${var.route53_zone}"
  type    = "A"

  alias {
    name                   = "${aws_alb.instance.dns_name}"
    zone_id                = "${aws_alb.instance.zone_id}"
    evaluate_target_health = true
  }
}
