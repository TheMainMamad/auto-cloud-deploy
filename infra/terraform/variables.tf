variable "api_key" {
  type        = string
  description = "ArvanCloud API key"
}

variable "abrak_name" {
  type    = string
  description = "ArvanCloud Abrak Name"
}

variable "region" {
  type        = string
  description = "Region for the Abrak server"
  default     = "ir-thr-fr1"  # Forogh DC
}

variable "flavor" {
  type    = string
  default = "eco-small1-1-1-0"
}

variable "disk_size" {
  type    = number
  default = 25
}

variable "image_type" {
  type    = string
  default = "distribution"
}

variable "image_name" {
  type    = string
  default = "ubuntu/24.04"
}
