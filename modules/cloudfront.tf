resource "aws_cloudfront_origin_access_identity" "api" {
  comment = "Origin access identity for ${var.name} ${var.env} api"
}

resource "aws_cloudfront_distribution" "api" {
  origin {
    domain_name = "${aws_s3_bucket.api.bucket_regional_domain_name}"
    origin_id   = "${var.name}_${var.env}_api"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.api.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  comment = "${var.name} ${var.env} api assets"

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.instance.arn}"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.name}_${var.env}_api"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}
