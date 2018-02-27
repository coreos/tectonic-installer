provider "aws" {
  region  = "${var.tectonic_aws_region}"
  profile = "${var.tectonic_aws_profile}"
  version = "1.8.0"

  assume_role {
    role_arn     = "${var.tectonic_aws_installer_role == "" ? "" : "${var.tectonic_aws_installer_role}"}"
    session_name = "TECTONIC_INSTALLER_${var.tectonic_cluster_name}"
  }
}

locals {
  ingress_internal_fqdn = "${var.tectonic_cluster_name}.${var.tectonic_base_domain}"
  api_internal_fqdn     = "${var.tectonic_cluster_name}-api.${var.tectonic_base_domain}"
  bucket_name           = "${var.tectonic_cluster_name}-ncg.${var.tectonic_base_domain}"
  bucket_assets_key     = "assets.zip"
}

data "aws_availability_zones" "azs" {}

data "template_file" "etcd_hostname_list" {
  count    = "${var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.aws_availability_zones.azs.names) == 5 ? 5 : 3}"
  template = "${var.tectonic_cluster_name}-etcd-${count.index}.${var.tectonic_base_domain}"
}

module "bootkube" {
  source         = "../../modules/bootkube-ut2"
  cloud_provider = "aws"

  cluster_name = "${var.tectonic_cluster_name}"

  kube_apiserver_url = "https://${local.api_internal_fqdn}:443"
  oidc_issuer_url    = "https://${local.ingress_internal_fqdn}/identity"

  # Platform-independent variables wiring, do not modify.
  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  service_cidr = "${var.tectonic_service_cidr}"
  cluster_cidr = "${var.tectonic_cluster_cidr}"

  advertise_address = "0.0.0.0"

  oidc_username_claim = "email"
  oidc_groups_claim   = "groups"
  oidc_client_id      = "tectonic-kubectl"
  oidc_ca_cert        = "${module.ingress_certs.ca_cert_pem}"

  pull_secret_path = "${pathexpand(var.tectonic_pull_secret_path)}"

  aggregator_ca_cert_pem   = "${module.kube_certs.aggregator_ca_cert_pem}"
  apiserver_cert_pem       = "${module.kube_certs.apiserver_cert_pem}"
  apiserver_key_pem        = "${module.kube_certs.apiserver_key_pem}"
  apiserver_proxy_cert_pem = "${module.kube_certs.apiserver_proxy_cert_pem}"
  apiserver_proxy_key_pem  = "${module.kube_certs.apiserver_proxy_key_pem}"
  etcd_ca_cert_pem         = "${module.etcd_certs.etcd_ca_crt_pem}"
  etcd_client_cert_pem     = "${module.etcd_certs.etcd_client_crt_pem}"
  etcd_client_key_pem      = "${module.etcd_certs.etcd_client_key_pem}"
  etcd_peer_cert_pem       = "${module.etcd_certs.etcd_peer_crt_pem}"
  etcd_peer_key_pem        = "${module.etcd_certs.etcd_peer_key_pem}"
  etcd_server_cert_pem     = "${module.etcd_certs.etcd_server_crt_pem}"
  etcd_server_key_pem      = "${module.etcd_certs.etcd_server_key_pem}"
  kube_ca_cert_pem         = "${module.kube_certs.ca_cert_pem}"
  kube_ca_key_pem          = "${module.kube_certs.ca_key_pem}"
  admin_cert_pem           = "${module.kube_certs.admin_cert_pem}"
  admin_key_pem            = "${module.kube_certs.admin_key_pem}"

  # need indent here https://github.com/hashicorp/terraform/issues/16775
  ncg_config_worker = "${indent(2, data.ignition_config.workers.rendered)}"
  ncg_config_master = "${indent(2, data.ignition_config.masters.rendered)}"

  etcd_endpoints = "${data.template_file.etcd_hostname_list.*.rendered}"
  master_count   = "${var.tectonic_master_count}"

  cloud_config_path   = ""
  tectonic_networking = "${var.tectonic_networking}"
  calico_mtu          = "1480"

  # ignition bootstrapping variables
  no_proxy                  = "${var.tectonic_no_proxy}"
  http_proxy                = "${var.tectonic_http_proxy_address}"
  https_proxy               = "${var.tectonic_https_proxy_address}"
  image_re                  = "${var.tectonic_image_re}"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
}

module "tectonic" {
  source   = "../../modules/tectonic"
  platform = "aws"

  cluster_name = "${var.tectonic_cluster_name}"

  base_address       = "${local.ingress_internal_fqdn}"
  kube_apiserver_url = "https://${local.api_internal_fqdn}:443"
  service_cidr       = "${var.tectonic_service_cidr}"

  # Platform-independent variables wiring, do not modify.
  container_images      = "${var.tectonic_container_images}"
  container_base_images = "${var.tectonic_container_base_images}"
  versions              = "${var.tectonic_versions}"

  license_path     = "${pathexpand(var.tectonic_license_path)}"
  pull_secret_path = "${pathexpand(var.tectonic_pull_secret_path)}"

  admin_email    = "${var.tectonic_admin_email}"
  admin_password = "${var.tectonic_admin_password}"

  update_channel = "${var.tectonic_update_channel}"
  update_app_id  = "${var.tectonic_update_app_id}"
  update_server  = "${var.tectonic_update_server}"

  ca_generated = "${var.tectonic_ca_cert == "" ? false : true}"
  ca_cert      = "${module.kube_certs.ca_cert_pem}"

  ingress_ca_cert_pem = "${module.ingress_certs.ca_cert_pem}"
  ingress_cert_pem    = "${module.ingress_certs.cert_pem}"
  ingress_key_pem     = "${module.ingress_certs.key_pem}"

  identity_client_cert_pem = "${module.identity_certs.client_cert_pem}"
  identity_client_key_pem  = "${module.identity_certs.client_key_pem}"
  identity_server_cert_pem = "${module.identity_certs.server_cert_pem}"
  identity_server_key_pem  = "${module.identity_certs.server_key_pem}"

  console_client_id = "tectonic-console"
  kubectl_client_id = "tectonic-kubectl"
  ingress_kind      = "NodePort"
  master_count      = "${var.tectonic_master_count}"
  stats_url         = "${var.tectonic_stats_url}"

  image_re = "${var.tectonic_image_re}"
}
