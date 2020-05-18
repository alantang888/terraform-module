provider "aws" {
  alias = "us-east-1"
}

locals {
  fqdn = "${var.host}.${var.zone}"
}

module "cert" {
  source = "../acm_request_with_subject_alternative_names"
  providers = {aws = "aws.us-east-1"}

  main_domain_zone_map = {
    "${local.fqdn}" = "${var.zone}."
  }
  sans_zone_map = {}
}

module "s3" {
  source = "../s3_with_iam"
  bucket_name = local.fqdn
  domain = "${var.zone}."
}

module "cloudfront" {
  source = "../config_cloudfront"
  acm_cert_arn = module.cert.cert_arn
  bucket_domain_name = module.s3.s3_bucket_domain
  origin_path = ""
  domain_zone_map = {
    "${local.fqdn}" = "${var.zone}."
  }

  iam_user_name = module.s3.iam_user
  add_dns_record = var.add_dns_record
}
