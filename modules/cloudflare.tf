resource "cloudflare_record" "acm" {
  domain = "${var.domain_name}"
  name   = "${aws_acm_certificate.instance.domain_validation_options.0.resource_record_name}"
  type   = "${aws_acm_certificate.instance.domain_validation_options.0.resource_record_type}"
  value  = "${aws_acm_certificate.instance.domain_validation_options.0.resource_record_value}"
}

resource "cloudflare_record" "api" {
  domain = "${var.domain_name}"
  name   = "api"
  value  = "${aws_alb.instance.dns_name}"
  type   = "CNAME"
}

resource "cloudflare_record" "api_assets" {
  domain = "${var.domain_name}"
  name   = "api-assets"
  value  = "${aws_cloudfront_distribution.api_assets.domain_name}"
  type   = "CNAME"
}

resource "cloudflare_record" "www" {
  domain = "${var.domain_name}"
  name   = "www"
  value  = "${aws_cloudfront_distribution.www.domain_name}"
  type   = "CNAME"

  proxied = false
}

resource "cloudflare_record" "www_redirect" {
  domain = "${var.domain_name}"
  name   = "${var.domain_name}"
  value  = "${aws_cloudfront_distribution.www_redirect.domain_name}"
  type   = "CNAME"

  proxied = false
}
