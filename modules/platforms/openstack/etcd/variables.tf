// The amount of etcd nodes to be created.
// Example: `3`
variable "count" {
  type = "string"
}

// The amount of internal etcd nodes to be created.
// Example: `3`
variable "count_internal" {
  type = "string"
}

variable "count_ignition" {
  type = "string"
}

// The network id of the internal network to be used for internal etcd nodes.
variable "network_id_internal" {
  type = "string"
}

// The name of the cluster.
// The etcd hostnames will be prefixed with this.
variable "cluster_name" {
  type = "string"
}

// The flavor ID as given in `openstack flavor list`.
// Specifies the size (CPU/Memory/Drive) of the VM.
variable "flavor_id" {
  type = "string"
}

// The image ID as given in `openstack image list`.
// Specifies the OS image of the VM.
variable "image_id" {
  type = "string"
}

// The public keys for the core user.
variable core_public_keys {
  type = "list"
}

output "ips_v4" {
  value = ["${openstack_compute_instance_v2.etcd_node.*.access_ip_v4}"]
}
