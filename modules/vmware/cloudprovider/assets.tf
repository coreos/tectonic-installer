# Cloud Provider Overrides for VMware
resource "template_folder" "cloudprovider" {
  input_path = "${path.module}/resources/manifests"
  output_path = "${path.cwd}/generated/cloudprovider"

  vars {
    hyperkube_image = "${var.container_images["hyperkube"]}"
    etcd_servers = "${join(",", var.etcd_servers)}"
    cloud_provider = "${var.cloud_provider}"

    cluster_cidr = "${var.cluster_cidr}"
    service_cidr = "${var.service_cidr}"

    advertise_address = "${var.advertise_address}"

    anonymous_auth = "${var.anonymous_auth}"
    oidc_issuer_url = "${var.oidc_issuer_url}"
    oidc_client_id = "${var.oidc_client_id}"
    oidc_username_claim = "${var.oidc_username_claim}"
    oidc_groups_claim = "${var.oidc_groups_claim}"
  }
}

