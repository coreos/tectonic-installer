output "ip_address" {
  value = ["${vsphere_virtual_machine.master_node.network_interface.0.ipv4_address}"]
}