variable "host" {
  type = "string"
}

variable "zone" {
  type = "string"
  description = "DNS Zone. No need put '.' at the end. will append it"
}

variable "add_dns_record" {
  type = bool
  default = true
  description = "Add DNS record of cloudfront"
}
