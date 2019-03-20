data "aws_route53_zone" "instance" {
  name = "${var.route53_zone}."
}

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

resource "aws_route53_record" "api_assets" {
  zone_id = "${data.aws_route53_zone.instance.zone_id}"
  name    = "api-assets.${var.route53_zone}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.api_assets.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.api_assets.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.instance.zone_id}"
  name    = "www.${var.route53_zone}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.www.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.www.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_redirect" {
  zone_id = "${data.aws_route53_zone.instance.zone_id}"
  name    = "${var.route53_zone}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.www_redirect.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.www_redirect.hosted_zone_id}"
    evaluate_target_health = false
  }
}
