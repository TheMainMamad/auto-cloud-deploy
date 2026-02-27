terraform {
  required_providers {
    virtualbox = {
        source = "terra-farm/virtualbox"
        version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm-name" {
  name = var.vm_name
  image = var.image_name
  cpus = var.cpu_count
  memory = var.memory_size
  network_adapter {
    type = var.network_type   
  }
}
