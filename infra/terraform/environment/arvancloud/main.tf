terraform {
  required_providers {
    arvan = {
      source  = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}


provider "arvan" {
  api_key = var.ApiKey
}


resource "arvan_abrak" "abrak-1" {
  region = var.region
  flavor_id = var.falvorId
  name   = var.abrakName
  image_id = var.imageId
  disk_size = var.diskSize
  ssh_key_name = var.ssh_key_name
  security_groups = [
    var.securityGroupId
  ]
}
