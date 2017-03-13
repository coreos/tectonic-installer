resource "openstack_compute_instance_v2" "master_node" {
  count           = "${var.count}"
  name            = "${var.cluster_name}_master_node_${count.index}"
  image_id        = "${var.image_id}"
  flavor_id       = "${var.flavor_id}"
  security_groups = ["${openstack_compute_secgroup_v2.k8s_master_group.name}"]

  metadata {
    role = "master"
  }

  user_data    = "${ignition_config.master.*.rendered[count.index]}"
  config_drive = false
}

resource "openstack_compute_instance_v2" "master_node_floating" {
  count           = "${var.count_floating}"
  name            = "${var.cluster_name}_master_node_${count.index}"
  image_id        = "${var.image_id}"
  flavor_id       = "${var.flavor_id}"
  security_groups = ["${openstack_compute_secgroup_v2.k8s_master_group.name}"]

  metadata {
    role = "master"
  }

  user_data    = "${ignition_config.master.*.rendered[count.index]}"
  config_drive = false

  network {
    floating_ip = "${var.floatingips[count.index]}"
    uuid        = "${var.network_id_internal}"
  }
}

resource "openstack_compute_secgroup_v2" "k8s_master_group" {
  name        = "${var.cluster_name}_k8s_master_group"
  description = "security group for k8s masters: SSH and https"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}
