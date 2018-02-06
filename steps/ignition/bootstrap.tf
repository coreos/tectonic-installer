provider "aws" {
  region  = "${var.tectonic_aws_region}"
  profile = "${var.tectonic_aws_profile}"
  version = "1.7.0"
}

data "aws_availability_zones" "azs" {}

data "template_file" "etcd_hostname_list" {
  count    = "${var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.aws_availability_zones.azs.names) == 5 ? 5 : 3}"
  template = "${var.tectonic_cluster_name}-etcd-${count.index}.${var.tectonic_base_domain}"
}

/*
This is the ignition config for the bootstrap node.
At the moment this matches the ncg ignition config.
TODO: move this to a basic static ignition config file and force this machine to reignite consuming from NCG
*/
module "ignition_masters" {
  source = "../../modules/ignition"

  assets_location           = "${local.tectonic_bucket}/${local.tectonic_key}"
  base_domain               = "${var.tectonic_base_domain}"
  bootstrap_upgrade_cl      = "${var.tectonic_bootstrap_upgrade_cl}"
  cloud_provider            = "aws"
  cluster_name              = "${var.tectonic_cluster_name}"
  container_images          = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list   = "${var.tectonic_custom_ca_pem_list}"
  etcd_advertise_name_list  = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_ca_cert_pem          = "${local.etcd_ca_crt_pem}"
  etcd_client_crt_pem       = "${local.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${local.etcd_client_key_pem}"
  etcd_count                = "${length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_initial_cluster_list = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_peer_crt_pem         = "${local.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${local.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${local.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${local.etcd_server_key_pem}"
  image_re                  = "${var.tectonic_image_re}"
  ingress_ca_cert_pem       = "${local.ingress_certs_ca_cert_pem}"
  kube_ca_cert_pem          = "${local.kube_certs_ca_cert_pem}"
  kube_dns_service_ip       = "${local.kube_dns_service_ip}"
  kubelet_debug_config      = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  http_proxy                = "${var.tectonic_http_proxy_address}"
  https_proxy               = "${var.tectonic_https_proxy_address}"
  no_proxy                  = "${var.tectonic_no_proxy}"
  iscsi_enabled             = "${var.tectonic_iscsi_enabled}"
}

resource "aws_s3_bucket_object" "ignition_master" {
  bucket  = "${local.s3_bucket}"
  key     = "ignition"
  content = "${data.ignition_config.main.rendered}"
  acl     = "public-read"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "${var.tectonic_cluster_name}-ignition-master",
      "KubernetesCluster", "${var.tectonic_cluster_name}",
      "tectonicClusterID", "${local.cluster_id}"
    ), var.tectonic_aws_extra_tags)}"
}

data "ignition_config" "main" {
  files = [
    "${data.ignition_file.init_assets.id}",
    "${data.ignition_file.rm_assets.id}",
    "${module.ignition_masters.installer_kubelet_env_id}",
    "${module.ignition_masters.installer_runtime_mappings_id}",
    "${module.ignition_masters.max_user_watches_id}",
    "${module.ignition_masters.s3_puller_id}",
    "${module.ignition_masters.ca_cert_id_list}",
    "${module.ignition_masters.profile_env_id}",
    "${module.ignition_masters.systemd_default_env_id}",
  ]

  systemd = ["${compact(list(
    data.ignition_systemd_unit.bootkube_service.id,
    data.ignition_systemd_unit.bootkube_path_unit.id,
    data.ignition_systemd_unit.tectonic_service.id,
    data.ignition_systemd_unit.tectonic_path.id,
    module.ignition_masters.docker_dropin_id,
    module.ignition_masters.locksmithd_service_id,
    module.ignition_masters.kubelet_service_id,
    module.ignition_masters.k8s_node_bootstrap_service_id,
    module.ignition_masters.init_assets_service_id,
    module.ignition_masters.rm_assets_service_id,
    module.ignition_masters.rm_assets_path_unit_id,
    module.ignition_masters.update_ca_certificates_dropin_id,
    module.ignition_masters.iscsi_service_id,
   ))}"]
}

// ignition config requires id to be in the state so
// tectonic_id and bootkube_id can not be inputs
# tectonic.service (available as output variable)
data "template_file" "tectonic_service" {
  template = "${file("${path.module}/../../modules/tectonic/resources/tectonic.service")}"
}

data "ignition_systemd_unit" "tectonic_service" {
  name    = "tectonic.service"
  enabled = false
  content = "${data.template_file.tectonic_service.rendered}"
}

data "template_file" "tectonic_path" {
  template = "${file("${path.module}/../../modules/tectonic/resources/tectonic.path")}"
}

data "ignition_systemd_unit" "tectonic_path" {
  name    = "tectonic.path"
  enabled = true
  content = "${data.template_file.tectonic_path.rendered}"
}

data "template_file" "bootkube_service" {
  template = "${file("${path.module}/../../modules/bootkube/resources/bootkube.service")}"
}

data "ignition_systemd_unit" "bootkube_service" {
  name    = "bootkube.service"
  enabled = false
  content = "${data.template_file.bootkube_service.rendered}"
}

data "template_file" "bootkube_path_unit" {
  template = "${file("${path.module}/../../modules/bootkube/resources/bootkube.path")}"
}

data "ignition_systemd_unit" "bootkube_path_unit" {
  name    = "bootkube.path"
  enabled = true
  content = "${data.template_file.bootkube_path_unit.rendered}"
}

data "template_file" "init_assets" {
  template = "${file("${path.module}/resources/init-assets.sh")}"

  vars {
    cluster_name       = "${var.tectonic_cluster_name}"
    awscli_image       = "${var.tectonic_container_images["awscli"]}"
    assets_s3_location = "${local.tectonic_bucket}/${local.tectonic_key}"
  }
}

data "ignition_file" "init_assets" {
  filesystem = "root"
  path       = "/opt/init-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.init_assets.rendered}"
  }
}

data "template_file" "rm_assets" {
  template = "${file("${path.module}/resources/rm-assets.sh")}"

  vars {
    cluster_name       = "${var.tectonic_cluster_name}"
    awscli_image       = "${var.tectonic_container_images["awscli"]}"
    assets_s3_location = "${local.tectonic_bucket}/${local.tectonic_key}"
  }
}

data "ignition_file" "rm_assets" {
  filesystem = "root"
  path       = "/opt/rm-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.rm_assets.rendered}"
  }
}
