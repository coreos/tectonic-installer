output "user_data" {
  value = ["${ignition_config.node.*.rendered}"]
}

output "secgroup_name" {
  value = "${openstack_compute_secgroup_v2.node.name}"
}
