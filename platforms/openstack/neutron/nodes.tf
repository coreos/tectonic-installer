# etcd

resource "openstack_compute_instance_v2" "etcd_node" {
  count           = "${var.tectonic_etcd_count}"
  name            = "${var.tectonic_cluster_name}_etcd_node_${count.index}"
  image_id        = "${var.tectonic_openstack_image_id}"
  flavor_id       = "${var.tectonic_openstack_flavor_id}"
  security_groups = ["${module.etcd.secgroup_name}"]

  metadata {
    role = "etcd"
  }

  network {
    uuid = "${openstack_networking_network_v2.network.id}"
  }

  user_data    = "${module.etcd.user_data[count.index]}"
  config_drive = false
}

# master

resource "openstack_compute_instance_v2" "master_node" {
  count           = "${var.tectonic_master_count}"
  name            = "${var.tectonic_cluster_name}_master_node_${count.index}"
  image_id        = "${var.tectonic_openstack_image_id}"
  flavor_id       = "${var.tectonic_openstack_flavor_id}"
  security_groups = ["${module.nodes.master_secgroup_name}"]

  metadata {
    role = "master"
  }

  network {
    port = "${openstack_networking_port_v2.master.*.id[count.index]}"
  }

  user_data    = "${module.nodes.master_user_data[count.index]}"
  config_drive = false
}

resource "openstack_compute_floatingip_associate_v2" "master" {
  count = "${var.tectonic_master_count}"

  floating_ip = "${openstack_networking_floatingip_v2.master.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.master_node.*.id[count.index]}"
}

# worker

resource "openstack_compute_instance_v2" "worker_node" {
  count     = "${var.tectonic_worker_count}"
  name      = "${var.tectonic_cluster_name}_worker_node_${count.index}"
  image_id  = "${var.tectonic_openstack_image_id}"
  flavor_id = "${var.tectonic_openstack_flavor_id}"

  metadata {
    role = "worker"
  }

  network {
    port = "${openstack_networking_port_v2.worker.*.id[count.index]}"
  }

  user_data    = "${module.nodes.worker_user_data[count.index]}"
  config_drive = false
}

resource "openstack_compute_floatingip_associate_v2" "worker" {
  count = "${var.tectonic_master_count}"

  floating_ip = "${openstack_networking_floatingip_v2.worker.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.worker_node.*.id[count.index]}"
}

# tectonic assets

resource "null_resource" "tectonic" {
  depends_on = [
    "module.tectonic",
    "openstack_compute_instance_v2.master_node",
    "openstack_networking_port_v2.master",
    "openstack_networking_floatingip_v2.master",
  ]

  connection {
    host        = "${openstack_networking_floatingip_v2.master.*.address[0]}"
    private_key = "${module.secrets.core_private_key_pem}"
    user        = "core"
  }

  provisioner "file" {
    source      = "${path.cwd}/generated"
    destination = "$HOME/tectonic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt",
      "sudo rm -rf /opt/tectonic",
      "sudo mv /home/core/tectonic /opt/",
      "sudo systemctl start tectonic",
    ]
  }
}
