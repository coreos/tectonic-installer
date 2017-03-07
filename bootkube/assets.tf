# Kubernetes Manifests, ordered alphabetically.

## manifests/kube-apiserver.yaml
data "template_file" "kube-apiserver" {
  template = "${file("${path.module}/resources/manifests/kube-apiserver.yaml.tpl")}"

  vars {
    cloud_provider = "${var.cloud_provider}"
    etcd_servers = "${join(",", var.etcd_servers)}"
    hyperkube_image = "${var.hyperkube_image}"
    service_cidr = "${var.service_cidr}"
  }
}

## manifests/kube-apiserver-secret.yaml
data "template_file" "kube-apiserver-secret" {
  template = "${file("${path.module}/resources/manifests/kube-apiserver-secret.yaml.tpl")}"

  vars {
    apiserver_key = "${base64encode(tls_private_key.apiserver.private_key_pem)}"
    apiserver_cert = "${base64encode(tls_locally_signed_cert.apiserver.cert_pem)}"
    serviceaccount_pub = "${base64encode(tls_private_key.service-account.public_key_pem)}"
    ca_cert = "${base64encode(tls_self_signed_cert.kube-ca.cert_pem)}"
  }
}

## manifests/kube-controller-manager.yaml
data "template_file" "kube-controller-manager" {
  template = "${file("${path.module}/resources/manifests/kube-controller-manager.yaml.tpl")}"

  vars {
    cloud_provider = "${var.cloud_provider}"
    cluster_cidr = "${var.cluster_cidr}"
    hyperkube_image = "${var.hyperkube_image}"
  }
}

## manifests/kube-controller-manager-secret.yaml
data "template_file" "kube-controller-manager-secret" {
  template = "${file("${path.module}/resources/manifests/kube-controller-manager-secret.yaml.tpl")}"

  vars {
    serviceaccount_key = "${base64encode(tls_private_key.service-account.private_key_pem)}"
    ca_cert = "${base64encode(tls_self_signed_cert.kube-ca.cert_pem)}"
  }
}

## manifests/kube-dns.yaml
data "template_file" "kube-dns" {
  template = "${file("${path.module}/resources/manifests/kube-dns.yaml.tpl")}"

  vars {
    kube_dns_service_ip = "${var.kube_dns_service_ip}"
  }
}

## manifests/kube-flannel.yaml
data "template_file" "kube-flannel" {
  template = "${file("${path.module}/resources/manifests/kube-flannel.yaml.tpl")}"

  vars {
    cluster_cidr = "${var.cluster_cidr}"
  }
}

## manifests/kube-proxy.yaml
data "template_file" "kube-proxy" {
  template = "${file("${path.module}/resources/manifests/kube-proxy.yaml.tpl")}"

  vars {
    cluster_cidr = "${var.cluster_cidr}"
    hyperkube_image = "${var.hyperkube_image}"
  }
}

## manifests/kube-scheduler.yaml
data "template_file" "kube-scheduler" {
  template = "${file("${path.module}/resources/manifests/kube-scheduler.yaml.tpl")}"

  vars {
    hyperkube_image = "${var.hyperkube_image}"
  }
}

## manifests/pod-checkpoint-installer.yaml
data "template_file" "pod-checkpoint-installer" {
  template = "${file("${path.module}/resources/manifests/pod-checkpoint-installer.yaml.tpl")}"

  vars {
    pod_checkpointer_image = "${var.pod_checkpointer_image}"
  }
}

# Other assets

## kubeconfig
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig.tpl")}"

  vars {
    ca_cert = "${base64encode(tls_self_signed_cert.kube-ca.cert_pem)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}}"
    kubelet_key = "${base64encode(tls_private_key.kubelet.private_key_pem)}}"
    server = "${var.kube_apiserver_url}"
  }
}

## bootkube.service
data "template_file" "bootkube-service" {
  template = "${file("${path.module}/resources/bootkube.service.tpl")}"

  vars {
    "assets_path" = "${var.assets_path}"
    "bootkube_image" = "${var.bootkube_image}"
    "etcd_endpoint" = "${var.etcd_servers[0]}"
  }
}