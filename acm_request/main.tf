provider "aws" {
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

resource "aws_acm_certificate" "acm_req" {
  provider = "aws.us-east-1"
  domain_name = "${var.cert_host}.${var.dns_zone}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "domain_zone" {
  name = "${var.dns_zone}."
}

resource "aws_route53_record" "verify_record" {
  provider = "aws.us-east-1"
  zone_id = "${data.aws_route53_zone.domain_zone.zone_id}"
  name = "${aws_acm_certificate.acm_req.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.acm_req.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.acm_req.domain_validation_options.0.resource_record_value}"]
  ttl = 300
}

resource "aws_acm_certificate_validation" "acm_complete_verify" {
  provider = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.acm_req.arn}"
  validation_record_fqdns = ["${aws_route53_record.verify_record.fqdn}"]
}
