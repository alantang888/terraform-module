variable "bucket_domain_name" {
  type = "string"
}

variable "origin_path" {
  type = "string"
  default = "/"
}

variable "domain_zone_map" {
  type = "map"
  description = "This map key is main FQDN (must only have one key). value is zone name. Don't remember the tail `.`."
}

variable "acm_cert_arn" {
  type = "string"
}
