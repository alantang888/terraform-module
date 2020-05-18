resource "aws_cloudfront_distribution" "cloudfront" {

  enabled = true
  is_ipv6_enabled = true

  aliases = keys(var.domain_zone_map)
  comment = join(", ", keys(var.domain_zone_map))

  default_root_object = "index.html"

  origin {
    domain_name = var.bucket_domain_name
    origin_path = var.origin_path
    origin_id = "${var.bucket_domain_name}${var.origin_path}"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    forwarded_values {
      cookies {
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = var.acm_cert_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

//  custom_error_response {
//    error_code = 403
//    response_code = 200
//    response_page_path = "/index.html"
//    error_caching_min_ttl = 0
//  }
}

data "aws_route53_zone" "get_domain_zone" {
  count = length(var.domain_zone_map)
  name = element(values(var.domain_zone_map), count.index)
}

resource "aws_route53_record" "add_cloudfront_record_to_route53" {
  count = var.add_dns_record ? length(var.domain_zone_map) : 0
  zone_id = element(data.aws_route53_zone.get_domain_zone.*.zone_id, index(data.aws_route53_zone.get_domain_zone.*.name, var.domain_zone_map[element(keys(var.domain_zone_map), count.index)]))
  name = element(keys(var.domain_zone_map), count.index)
  type = "A"
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id = aws_cloudfront_distribution.cloudfront.hosted_zone_id
  }
}

resource "aws_iam_policy" "cf_invalidation_policy" {
  name = "cf-${keys(var.domain_zone_map)[0]}-invalidation"
  path = "/"
  description = "Policy for invalidation cloudfront cache"
  // the first { must at beggin of line. otherwise will have "invalid JSON policy" error.
  // ref: https://github.com/terraform-providers/terraform-provider-aws/issues/1873
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ],
        "Resource": "${aws_cloudfront_distribution.cloudfront.arn}"
      }
    ]
  }
  EOF
}

resource "aws_iam_user_policy_attachment" "bind_policy_to_user" {
  policy_arn = aws_iam_policy.cf_invalidation_policy.arn
  user = var.iam_user_name
}
