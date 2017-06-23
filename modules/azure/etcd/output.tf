output "node_names" {
  value = "${azurerm_virtual_machine.etcd_node.*.os_profile.computer_name}"
}
