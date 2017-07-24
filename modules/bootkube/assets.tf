resource "template_dir" "experimental" {
  count           = "${var.experimental_enabled ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/manifests"
  destination_dir = "./generated/experimental"

  vars {
    etcd_operator_image = "${var.container_images["etcd_operator"]}"
    etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
    kenc_image          = "${var.container_images["kenc"]}"
    etcd_ca_cert        = "${base64encode(data.template_file.etcd_ca_cert_pem.rendered)}"
    etcd_client_cert    = "${base64encode(data.template_file.etcd_client_crt.rendered)}"
    etcd_client_key     = "${base64encode(data.template_file.etcd_client_key.rendered)}"
    etcd_peer_cert      = "${base64encode(join("", tls_locally_signed_cert.etcd_peer.*.cert_pem))}"
    etcd_peer_key       = "${base64encode(join("", tls_private_key.etcd_peer.*.private_key_pem))}"
  }
}

resource "template_dir" "bootstrap-experimental" {
  count           = "${var.experimental_enabled ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/bootstrap-manifests"
  destination_dir = "./generated/bootstrap-experimental"

  vars {
    etcd_image                = "${var.container_images["etcd"]}"
    etcd_version              = "${var.versions["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

resource "template_dir" "etcd-experimental" {
  count           = "${var.experimental_enabled ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/etcd"
  destination_dir = "./generated/etcd"

  vars {
    etcd_version              = "${var.versions["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# Self-hosted manifests (resources/generated/manifests/)
resource "template_dir" "bootkube" {
  source_dir      = "${path.module}/resources/manifests"
  destination_dir = "./generated/manifests"

  vars {
    hyperkube_image        = "${var.container_images["hyperkube"]}"
    pod_checkpointer_image = "${var.container_images["pod_checkpointer"]}"
    kubedns_image          = "${var.container_images["kubedns"]}"
    kubednsmasq_image      = "${var.container_images["kubednsmasq"]}"
    kubedns_sidecar_image  = "${var.container_images["kubedns_sidecar"]}"
    flannel_image          = "${var.container_images["flannel"]}"
    flannel_cni_image      = "${var.container_images["flannel_cni"]}"

    # Choose the etcd endpoints to use.
    # 1. If experimental mode is enabled (self-hosted etcd), then use
    # var.etcd_service_ip.
    # 2. Else if no etcd TLS certificates are provided, i.e. we bootstrap etcd
    # nodes ourselves (using http), then use insecure http var.etcd_endpoints.
    # 3. Else (if etcd TLS certific are provided), then use the secure https
    # var.etcd_endpoints.
    etcd_servers = "${
      var.experimental_enabled
        ? format("https://%s:2379", cidrhost(var.service_cidr, 15))
        : data.template_file.etcd_ca_cert_pem.rendered == ""
          ? join(",", formatlist("http://%s:2379", var.etcd_endpoints))
          : join(",", formatlist("https://%s:2379", var.etcd_endpoints))
      }"

    etcd_service_ip           = "${cidrhost(var.service_cidr, 15)}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"

    cloud_provider = "${var.cloud_provider}"

    cluster_cidr        = "${var.cluster_cidr}"
    service_cidr        = "${var.service_cidr}"
    kube_dns_service_ip = "${cidrhost(var.service_cidr, 10)}"
    advertise_address   = "${var.advertise_address}"

    anonymous_auth      = "${var.anonymous_auth}"
    oidc_issuer_url     = "${var.oidc_issuer_url}"
    oidc_client_id      = "${var.oidc_client_id}"
    oidc_username_claim = "${var.oidc_username_claim}"
    oidc_groups_claim   = "${var.oidc_groups_claim}"

    ca_cert            = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    apiserver_key      = "${base64encode(tls_private_key.apiserver.private_key_pem)}"
    apiserver_cert     = "${base64encode(tls_locally_signed_cert.apiserver.cert_pem)}"
    serviceaccount_pub = "${base64encode(tls_private_key.service-account.public_key_pem)}"
    serviceaccount_key = "${base64encode(tls_private_key.service-account.private_key_pem)}"

    etcd_ca_flag   = "${data.template_file.etcd_ca_cert_pem.rendered != "" ? "- --etcd-cafile=/etc/kubernetes/secrets/etcd-ca.crt" : "# no etcd-ca.crt given" }"
    etcd_cert_flag = "${data.template_file.etcd_client_crt.rendered != "" ? "- --etcd-certfile=/etc/kubernetes/secrets/etcd-client.crt" : "# no etcd-client.crt given" }"
    etcd_key_flag  = "${data.template_file.etcd_client_key.rendered != "" ? "- --etcd-keyfile=/etc/kubernetes/secrets/etcd-client.key" : "# no etcd-client.key given" }"

    etcd_ca_cert     = "${base64encode(data.template_file.etcd_ca_cert_pem.rendered)}"
    etcd_client_cert = "${base64encode(data.template_file.etcd_client_crt.rendered)}"
    etcd_client_key  = "${base64encode(data.template_file.etcd_client_key.rendered)}"

    tectonic_version = "${var.versions["tectonic"]}"

    master_count = "${var.master_count}"
  }
}

# Self-hosted bootstrapping manifests (resources/generated/manifests-bootstrap/)
resource "template_dir" "bootkube-bootstrap" {
  source_dir      = "${path.module}/resources/bootstrap-manifests"
  destination_dir = "./generated/bootstrap-manifests"

  vars {
    hyperkube_image = "${var.container_images["hyperkube"]}"
    etcd_image      = "${var.container_images["etcd"]}"

    etcd_servers = "${
      var.experimental_enabled
        ? format("https://%s:2379,https://127.0.0.1:12379", cidrhost(var.service_cidr, 15))
        : data.template_file.etcd_ca_cert_pem.rendered == ""
          ? join(",", formatlist("http://%s:2379", var.etcd_endpoints))
          : join(",", formatlist("https://%s:2379", var.etcd_endpoints))
      }"

    etcd_ca_flag   = "${data.template_file.etcd_ca_cert_pem.rendered != "" ? "- --etcd-cafile=/etc/kubernetes/secrets/operator/etcd-ca-crt.pem" : "# no etcd-ca.crt given" }"
    etcd_cert_flag = "${data.template_file.etcd_client_crt.rendered != "" ? "- --etcd-certfile=/etc/kubernetes/secrets/operator/etcd-crt.pem" : "# no etcd-client.crt given" }"
    etcd_key_flag  = "${data.template_file.etcd_client_key.rendered != "" ? "- --etcd-keyfile=/etc/kubernetes/secrets/operator/etcd-key.pem" : "# no etcd-client.key given" }"

    advertise_address = "${var.advertise_address}"
    cloud_provider    = "${var.cloud_provider}"
    cluster_cidr      = "${var.cluster_cidr}"
    service_cidr      = "${var.service_cidr}"
  }
}

# kubeconfig (resources/generated/auth/kubeconfig)
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
    kubelet_key  = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
    server       = "${var.kube_apiserver_url}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "./generated/auth/kubeconfig"
}

# bootkube.sh (resources/generated/bootkube.sh)
data "template_file" "bootkube-sh" {
  template = "${file("${path.module}/resources/bootkube.sh")}"

  vars {
    bootkube_image = "${var.container_images["bootkube"]}"
  }
}

resource "local_file" "bootkube-sh" {
  content  = "${data.template_file.bootkube-sh.rendered}"
  filename = "./generated/bootkube.sh"
}

# bootkube.service (available as output variable)
data "template_file" "bootkube_service" {
  template = "${file("${path.module}/resources/bootkube.service")}"
}

# etcd assets
data "template_file" "etcd_ca_cert_pem" {
  template = "${var.experimental_enabled || var.etcd_tls_enabled
    ? join("", tls_self_signed_cert.etcd-ca.*.cert_pem)
    : file(var.etcd_ca_cert)
  }"
}

data "template_file" "etcd_client_crt" {
  template = "${var.experimental_enabled || var.etcd_tls_enabled
    ? join("", tls_locally_signed_cert.etcd_client.*.cert_pem)
    : file(var.etcd_client_cert)
  }"
}

data "template_file" "etcd_client_key" {
  template = "${var.experimental_enabled || var.etcd_tls_enabled
    ? join("", tls_private_key.etcd_client.*.private_key_pem)
    : file(var.etcd_client_cert)
  }"
}

resource "local_file" "etcd_ca_crt" {
  count    = "${var.experimental_enabled || var.etcd_tls_enabled ? 1 : 0}"
  content  = "${data.template_file.etcd_ca_cert_pem.rendered}"
  filename = "./generated/tls/operator/etcd-ca-crt.pem"
}

resource "local_file" "etcd_client_crt" {
  count    = "${var.experimental_enabled || var.etcd_tls_enabled ? 1 : 0}"
  content  = "${data.template_file.etcd_client_crt.rendered}"
  filename = "./generated/tls/operator/etcd-crt.pem"
}

resource "local_file" "etcd_client_key" {
  count    = "${var.experimental_enabled || var.etcd_tls_enabled ? 1 : 0}"
  content  = "${data.template_file.etcd_client_key.rendered}"
  filename = "./generated/tls/operator/etcd-key.pem"
}

resource "local_file" "etcd_peer_crt" {
  count    = "${var.experimental_enabled || var.etcd_tls_enabled ? 1 : 0}"
  content  = "${join("", tls_locally_signed_cert.etcd_peer.*.cert_pem)}"
  filename = "./generated/tls/peer/etcd-peer.crt"
}

resource "local_file" "etcd_peer_key" {
  count    = "${var.experimental_enabled || var.etcd_tls_enabled ? 1 : 0}"
  content  = "${join("", tls_private_key.etcd_peer.*.private_key_pem)}"
  filename = "./generated/tls/peer/etcd-peer.key"
}
