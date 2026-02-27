output "vm-id" {
  value = virtualbox_vm.vm-name.id
}

output "vm-ip" {
  value = virtualbox_vm.vm-name.network_adapter[0].ipv4_address
}
