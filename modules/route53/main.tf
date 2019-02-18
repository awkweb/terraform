resource "aws_route53_zone" "primary_route" {
  name = "${var.domain}."
}

resource "aws_route53_record" "www-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${var.name}"
    zone_id                = "${var.zone_id}"
    evaluate_target_health = true
  }
}
