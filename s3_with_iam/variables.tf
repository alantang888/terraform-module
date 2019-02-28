variable "bucket_name" {
  type = "string"
}

variable "bucket_prefix" {
  type = "string"
  default = "lalamove-"
}

variable "create_folder" {
  default = false
}