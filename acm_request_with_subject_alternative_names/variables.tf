variable "main_domain_zone_map" {
  type = "map"
  description = "This map key is main FQDN (must only have one key). value is zone name. Don't remember the tail `.`."
}

variable "sans_zone_map" {
  type = "map"
  description = "This map key is SAN FQDN. value is zone name. Don't remember the tail `.`. And each domain use for SAN need put on here. Even domains in same zone."
}