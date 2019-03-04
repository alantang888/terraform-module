resource "aws_acm_certificate" "acm_req" {
  domain_name = "${element(keys(var.main_domain_zone_map), 0)}"
  subject_alternative_names = "${keys(var.sans_zone_map)}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals{
  merged_domain_zone_map = "${merge(var.main_domain_zone_map, var.sans_zone_map)}"
}

data "aws_route53_zone" "domain_zoneid_lookup" {
  count = "${length(local.merged_domain_zone_map)}"
  name = "${element(values(local.merged_domain_zone_map), count.index)}"
}

resource "aws_route53_record" "create_acm_verify_record" {
  depends_on = ["aws_acm_certificate.acm_req", "data.aws_route53_zone.domain_zoneid_lookup"]

  count = "${length(local.merged_domain_zone_map)}"
  zone_id = "${element(data.aws_route53_zone.domain_zoneid_lookup.*.zone_id, index(data.aws_route53_zone.domain_zoneid_lookup.*.name, local.merged_domain_zone_map[lookup(aws_acm_certificate.acm_req.domain_validation_options[count.index], "domain_name")]))}"
  name = "${lookup(aws_acm_certificate.acm_req.domain_validation_options[count.index], "resource_record_name")}"
  type = "${lookup(aws_acm_certificate.acm_req.domain_validation_options[count.index], "resource_record_type")}"
  records = ["${lookup(aws_acm_certificate.acm_req.domain_validation_options[count.index], "resource_record_value")}"]
  ttl = 300
}

resource "aws_acm_certificate_validation" "acm_complete_verify" {
  depends_on = ["aws_route53_record.create_acm_verify_record"]
  certificate_arn = "${aws_acm_certificate.acm_req.arn}"
//  validation_record_fqdns = "${keys(local.merged_domain_zone_map)}"
}
