resource "openstack_networking_router_v2" "router" {
  name             = "${var.tectonic_cluster_name}_router"
  admin_state_up   = "true"
  external_gateway = "${var.tectonic_openstack_external_gateway_id}"
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.tectonic_cluster_name}_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${var.tectonic_cluster_name}_subnet"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr       = "${var.tectonic_openstack_subnet_cidr}"
  ip_version = 4

  dns_nameservers = ["${var.tectonic_openstack_dns_nameservers}"]
}

resource "openstack_networking_router_interface_v2" "interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

# etcd

resource "openstack_networking_port_v2" "etcd" {
  count              = "${var.tectonic_etcd_count}"
  name               = "${var.tectonic_cluster_name}_port_etcd_${count.index}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${module.etcd.secgroup_id}"]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

# master

resource "openstack_networking_port_v2" "master" {
  count              = "${var.tectonic_master_count}"
  name               = "${var.tectonic_cluster_name}_port_master_${count.index}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${module.master_nodes.secgroup_master_id}"]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }

  allowed_address_pairs {
    ip_address = "${var.tectonic_service_cidr}"
  }

  allowed_address_pairs {
    ip_address = "${var.tectonic_cluster_cidr}"
  }
}

resource "openstack_networking_floatingip_v2" "master" {
  count = "${var.tectonic_master_count}"
  pool  = "${var.tectonic_openstack_floatingip_pool}"
}

# worker

resource "openstack_networking_port_v2" "worker" {
  count              = "${var.tectonic_worker_count}"
  name               = "${var.tectonic_cluster_name}_port_worker_${count.index}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${module.worker_nodes.secgroup_node_id}"]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }

  allowed_address_pairs {
    ip_address = "${var.tectonic_service_cidr}"
  }

  allowed_address_pairs {
    ip_address = "${var.tectonic_cluster_cidr}"
  }
}

resource "openstack_networking_floatingip_v2" "worker" {
  count = "${var.tectonic_worker_count}"
  pool  = "${var.tectonic_openstack_floatingip_pool}"
}
