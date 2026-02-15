terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/arvancloud"
    }
  }
}

provider "arvan" {
  api_key = var.api_key
}
