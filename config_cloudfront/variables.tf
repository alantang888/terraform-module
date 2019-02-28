variable "bucket_domain_name" {
  type = "string"
}

variable "origin_path" {
  type = "string"
  default = "/"
}

variable "dns_zone" {
  type = "string"
}

variable "host" {
  type = "string"
}

variable "acm_cert_arn" {
  type = "string"
}
