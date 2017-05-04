module "bootkube" {
  source         = "../../modules/bootkube"
  cloud_provider = ""

  kube_apiserver_url = "${var.tectonic_azure_use_custom_fqdn == "true" ? "https://${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}:443" : "https://${module.masters.api_internal_fqdn}:443"}"
  oidc_issuer_url    = "${var.tectonic_azure_use_custom_fqdn == "true" ? "https://${var.tectonic_cluster_name}.${var.tectonic_base_domain}/identity" : "https://${module.masters.ingress_internal_fqdn}/identity"}"

  # Platform-independent variables wiring, do not modify.
  container_images = "${var.tectonic_container_images}"

  ca_cert    = "${var.tectonic_ca_cert}"
  ca_key     = "${var.tectonic_ca_key}"
  ca_key_alg = "${var.tectonic_ca_key_alg}"

  service_cidr = "${var.tectonic_service_cidr}"
  cluster_cidr = "${var.tectonic_cluster_cidr}"

  kube_apiserver_service_ip = "${var.tectonic_kube_apiserver_service_ip}"
  kube_dns_service_ip       = "${var.tectonic_kube_dns_service_ip}"

  advertise_address = "0.0.0.0"
  anonymous_auth    = "false"

  oidc_username_claim = "email"
  oidc_groups_claim   = "groups"
  oidc_client_id      = "tectonic-kubectl"

  etcd_endpoints   = ["${module.etcd.ip_address}"]
  etcd_ca_cert     = "${var.tectonic_etcd_ca_cert_path}"
  etcd_client_cert = "${var.tectonic_etcd_client_cert_path}"
  etcd_client_key  = "${var.tectonic_etcd_client_key_path}"
}

module "tectonic" {
  source   = "../../modules/tectonic"
  platform = "azure"

  base_address       = "${var.tectonic_azure_use_custom_fqdn == "true" ? "${var.tectonic_cluster_name}.${var.tectonic_base_domain}" : module.masters.ingress_internal_fqdn}"
  kube_apiserver_url = "${var.tectonic_azure_use_custom_fqdn == "true" ? "https://${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}:443" : "https://${module.masters.api_internal_fqdn}:443"}"

  # Platform-independent variables wiring, do not modify.
  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  license_path     = "${pathexpand(var.tectonic_license_path)}"
  pull_secret_path = "${pathexpand(var.tectonic_pull_secret_path)}"

  admin_email         = "${var.tectonic_admin_email}"
  admin_password_hash = "${var.tectonic_admin_password_hash}"

  update_channel = "${var.tectonic_update_channel}"
  update_app_id  = "${var.tectonic_update_app_id}"
  update_server  = "${var.tectonic_update_server}"

  ca_generated = "${module.bootkube.ca_cert == "" ? false : true}"
  ca_cert      = "${module.bootkube.ca_cert}"
  ca_key_alg   = "${module.bootkube.ca_key_alg}"
  ca_key       = "${module.bootkube.ca_key}"

  console_client_id = "tectonic-console"
  kubectl_client_id = "tectonic-kubectl"
  ingress_kind      = "NodePort"
  experimental      = "${var.tectonic_experimental}"
}

resource "null_resource" "tectonic" {
  depends_on = ["module.tectonic", "module.masters"]

  triggers {
    api-endpoint = "${var.tectonic_azure_use_custom_fqdn == "true" ? "${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}" : module.masters.api_external_fqdn}"
  }

  connection {
    host  = "${var.tectonic_azure_use_custom_fqdn == "true" ? "${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}" : module.masters.api_external_fqdn}"
    user  = "core"
    agent = true
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
