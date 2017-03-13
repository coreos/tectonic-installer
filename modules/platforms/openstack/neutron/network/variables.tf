variable "master_count" {
  type = "string"
}

variable "worker_count" {
  type = "string"
}

// The name of the cluster.
variable "cluster_name" {
  type = "string"
}

variable "external_gateway_id" {
  type = "string"
}

output "floating_ips" {
  value = ["${openstack_compute_floatingip_v2.master.*.address}"]
}

output "id" {
  value = "${openstack_networking_network_v2.network.id}"
}
