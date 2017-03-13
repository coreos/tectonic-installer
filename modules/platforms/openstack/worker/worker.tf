resource "openstack_compute_instance_v2" "worker_node" {
  count     = "${var.count}"
  name      = "${var.cluster_name}_worker_node_${count.index}"
  image_id  = "${var.image_id}"
  flavor_id = "${var.flavor_id}"

  metadata {
    role = "worker"
  }

  user_data    = "${ignition_config.worker.*.rendered[count.index]}"
  config_drive = false
}
