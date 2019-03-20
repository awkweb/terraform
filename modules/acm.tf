resource "aws_acm_certificate" "instance" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.instance.arn}"
  validation_record_fqdns = ["${cloudflare_record.acm.hostname}"]
}
