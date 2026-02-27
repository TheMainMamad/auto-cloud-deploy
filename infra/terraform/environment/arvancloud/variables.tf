variable "ApiKey" {
  type = string
  sensitive = true
}

variable "diskSize" {
  type = number
  default = 25 # minimium disk size
}

variable "falvorId" {
  type = string
  default = "eco-1-1-0" # minimum plan of Forough DC
}

variable "abrakName" {
  type = string
  default = "Ubuntu Test" # name of instance
}

variable "imageId" {
  type = string
  default = "80827085-61a9-45dd-a9b1-04356e8b3987" # Ubuntu 24.04
}

variable "securityGroupId" {
  type = string
  default = "cd7b4134-5fab-41f6-9be6-bee4183b52ba" # Default Arvancloud security group
}

variable "networkId" {
  type = string
  default = "33c37a96-8cdc-4f93-93ea-baf80b09de5a" # Default Arvancloud network Id
}

variable "region" {
  type = string
  default = "ir-thr-fr1" # Forogh Datacenter
}

variable "ssh_key_name" {
  type = string
}