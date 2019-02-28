resource "aws_cloudfront_distribution" "cloudfront" {

  enabled = true
  is_ipv6_enabled = true

  aliases = ["${var.host}.${var.dns_zone}"]
  comment = "${var.host}.${var.dns_zone}"

  default_root_object = "index.html"

  "origin" {
    domain_name = "${var.bucket_domain_name}"
    origin_path = "${var.origin_path}"
    origin_id = "${var.bucket_domain_name}${var.origin_path}"
  }

  "default_cache_behavior" {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    "forwarded_values" {
      "cookies" {
        forward = "none"
      }
      query_string = false
    }
    target_origin_id = "${var.bucket_domain_name}${var.origin_path}"
    viewer_protocol_policy = "redirect-to-https"

    min_ttl = 0
    default_ttl = 180
    max_ttl = 180

    compress = true
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }
  "viewer_certificate" {
    acm_certificate_arn = "${var.acm_cert_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 0
  }
}

data "aws_route53_zone" "get_domain_zone" {
  name = "${var.dns_zone}."
}

resource "aws_route53_record" "add_cloudfront_record_to_route53" {
  zone_id = "${data.aws_route53_zone.get_domain_zone.zone_id}"
  name = "${var.host}.${var.dns_zone}"
  type = "A"
  alias {
    evaluate_target_health = false
    name = "${aws_cloudfront_distribution.cloudfront.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cloudfront.hosted_zone_id}"
  }
}
