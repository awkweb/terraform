resource "aws_route53_delegation_set" "main" {
  reference_name = "DynDNS"
}

resource "aws_route53_zone" "primary_route" {
  name              = "${var.domain}"
  delegation_set_id = "${aws_route53_delegation_set.main.id}"
}

resource "aws_route53_record" "www-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = "${var.dns_name}"
    zone_id                = "${var.zone_id}"
    evaluate_target_health = true
  }
}
