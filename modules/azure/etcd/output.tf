# Used to force a dependency on vm creation before the output of the etcd
# module can be used due to a lack of depends_on in a module declaration
output "id" {
  value = "${sha1("${join("", azurerm_virtual_machine.etcd_node.*.id)}")}"
}

output "endpoints" {
  value = ["${split(",", length(var.external_endpoints) == 0 ? join(",", azurerm_network_interface.etcd_nic.*.private_ip_address) : join(",", var.external_endpoints))}"]
}
