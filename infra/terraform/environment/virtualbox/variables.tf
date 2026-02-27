variable "vm_name" {
  type = string
  description = "Virtual Machine name. default: 'terraform-vm-example'"
  default = "terraform"
}

variable "cpu_count" {
  type = number
  description = "Number of CPUs to assign to the virtual machine. default: 1"
  default = 1
}

variable "memory_size" {
  type = string
  description = "Memory size in MB. default: 512"
  default = "512 mib"
}

variable "image_name" {
  type = string
  description = "The name of the image to use for the virtual machine. default: 'ubuntu/bionic64'" 
  default = "https://app.vagrantup.com/arm64-boxes/boxes/ubuntu-22.04/versions/0.2/providers/virtualbox.box"
}

variable "network_type" {
  type = string
  description = "The type of network adapter to use (e.g., 'nat', 'bridged', 'hostonly') default: 'nat'"
  default = "nat"
}
