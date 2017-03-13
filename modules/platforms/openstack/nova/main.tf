module "dns" {
  source = "./dns"

  cluster_name = "${var.tectonic_cluster_name}"
  base_domain  = "${var.tectonic_base_domain}"

  etcd_records = ["${module.etcd.ips_v4}"]

  master_records = ["${module.master.ips_v4}"]
  master_count   = "${var.tectonic_master_count}"

  worker_records = ["${module.worker.ips_v4}"]
  worker_count   = "${var.tectonic_worker_count}"

  tectonic_console_records = ["${module.worker.ips_v4}"]
  tectonic_api_records     = ["${module.master.ips_v4}"]
}

module "etcd" {
  source = "./../etcd"

  count          = "1"
  count_ignition = "1"

  // disable internal etcd for nova
  count_internal      = "0"
  network_id_internal = ""

  cluster_name = "${var.tectonic_cluster_name}"
  flavor_id    = "${var.tectonic_openstack_flavor_id}"
  image_id     = "${var.tectonic_openstack_image_id}"

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

data "null_data_source" "local" {
  inputs = {
    kube_image_url = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kube_image_tag = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  }
}

module "master" {
  source = "./../master"

  resolv_conf_content = <<EOF
search ${var.tectonic_base_domain}
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

  kubeconfig_content = "${file("${var.tectonic_assets_dir}/auth/kubeconfig")}"
  etcd_fqdns         = ["${var.tectonic_cluster_name}-etc.${var.tectonic_base_domain}"]
  flavor_id          = "${var.tectonic_openstack_flavor_id}"
  image_id           = "${var.tectonic_openstack_image_id}"
  cluster_name       = "${var.tectonic_cluster_name}"
  count              = "${var.tectonic_master_count}"
  count_ignition     = "${var.tectonic_master_count}"
  kube_image_url     = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag     = "${data.null_data_source.local.outputs.kube_image_tag}"

  // disable internal master nodes for nova
  count_floating      = "0"
  network_id_internal = ""
  floatingips         = [""]

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

module "bootkube" {
  source = "./../../../bootkube"

  trigger_ids      = "${module.master.node_ids}"
  assets_dir       = "${var.tectonic_assets_dir}"
  core_private_key = "${module.secrets.core_private_key_pem}"
  hosts            = "${module.master.ips_v4}"
}

module "worker" {
  source = "./../worker"

  resolv_conf_content = <<EOF
search ${var.tectonic_base_domain}
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

  count              = "${var.tectonic_worker_count}"
  flavor_id          = "${var.tectonic_openstack_flavor_id}"
  image_id           = "${var.tectonic_openstack_image_id}"
  cluster_name       = "${var.tectonic_cluster_name}"
  kubeconfig_content = "${file("${var.tectonic_assets_dir}/auth/kubeconfig")}"
  kube_image_url     = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag     = "${data.null_data_source.local.outputs.kube_image_tag}"

  etcd_fqdns       = ["${var.tectonic_cluster_name}-etc.${var.tectonic_base_domain}"]
  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

module "secrets" {
  source       = "./../secrets"
  cluster_name = "${var.tectonic_cluster_name}"
}
