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

// The amount of worker nodes to be created.
// Example: `3`
variable "count" {
  type = "string"
}

// The name of the cluster.
// The worker hostnames will be prefixed with this.
variable "cluster_name" {
  type = "string"
}

// The content of the kubeconfig file.
variable kubeconfig_content {
  type = "string"
}

// The content of the /etc/resolv.conf file.
variable resolv_conf_content {
  type = "string"
}

// The fqdns of the etcd endpoints.
variable etcd_fqdns {
  type = "list"
}

// The hyperkube image tag.
variable kube_image_tag {
  type = "string"
}

// The hyperkube image url.
variable kube_image_url {
  type = "string"
}

// The public keys for the core user
variable core_public_keys {
  type = "list"
}

output "ips_v4" {
  value = ["${openstack_compute_instance_v2.worker_node.*.access_ip_v4}"]
}
