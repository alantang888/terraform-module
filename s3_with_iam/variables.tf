variable "bucket_name" {
  type = "string"
}

variable "bucket_prefix" {
  type = "string"
  default = ""
}

variable "create_folder" {
  default = false
}