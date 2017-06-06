# TODO: Add support for user-provided CA

resource "null_resource" "bootkube" {
  triggers {
    host = "${var.host}"
  }

  connection {
    host = "${var.host}"
    user = "${var.user}"
    private_key = "${var.private_key}"
    agent = true
  }

  ## Assets folder
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.assets_path}/manifests ${var.assets_path}/tls",
    ]
  }

  # Kubernetes Assets
  # Manifests are ordered alphabetically.

  ## manifests/kube-apiserver.yaml
  provisioner "file" {
    content = "${data.template_file.kube-apiserver.rendered}"
    destination = "${var.assets_path}/manifests/kube-apiserver.yaml"
  }

  ## manifests/kube-apiserver-secret.yaml
  provisioner "file" {
    content = "${data.template_file.kube-apiserver-secret.rendered}"
    destination = "${var.assets_path}/manifests/kube-apiserver-secret.yaml"
  }

  ## manifests/kube-controller-manager.yaml
  provisioner "file" {
    content = "${data.template_file.kube-controller-manager.rendered}"
    destination = "${var.assets_path}/manifests/kube-controller-manager.yaml"
  }

  ## manifests/kube-controller-manager-disruption.yaml
  provisioner "file" {
    source = "${path.module}/resources/manifests/kube-controller-manager-disruption.yaml"
    destination = "${var.assets_path}/manifests/kube-controller-manager-disruption.yaml"
  }

  ## manifests/kube-controller-manager-secret.yaml
  provisioner "file" {
    content = "${data.template_file.kube-controller-manager-secret.rendered}"
    destination = "${var.assets_path}/manifests/kube-controller-manager-secret.yaml"
  }

  ## manifests/kube-dns.yaml
  provisioner "file" {
    content = "${data.template_file.kube-dns.rendered}"
    destination = "${var.assets_path}/manifests/kube-dns.yaml"
  }

  ## manifests/kube-flannel.yaml
  provisioner "file" {
    content = "${data.template_file.kube-flannel.rendered}"
    destination = "${var.assets_path}/manifests/kube-flannel.yaml"
  }

  ## manifests/kube-proxy.yaml
  provisioner "file" {
    content = "${data.template_file.kube-proxy.rendered}"
    destination = "${var.assets_path}/manifests/kube-proxy.yaml"
  }

  ## manifests/kube-scheduler.yaml
  provisioner "file" {
    content = "${data.template_file.kube-scheduler.rendered}"
    destination = "${var.assets_path}/manifests/kube-scheduler.yaml"
  }

  ## manifests/kube-scheduler-disruption.yaml
  provisioner "file" {
    source = "${path.module}/resources/manifests/kube-scheduler-disruption.yaml"
    destination = "${var.assets_path}/manifests/kube-scheduler-disruption.yaml"
  }

  ## manifests/kube-system-rbac-role-binding.yaml
  provisioner "file" {
    source = "${path.module}/resources/manifests/kube-system-rbac-role-binding.yaml"
    destination = "${var.assets_path}/manifests/kube-system-rbac-role-binding.yaml"
  }

  ## manifests/pod-checkpoint-installer.yaml
  provisioner "file" {
    content = "${data.template_file.pod-checkpoint-installer.rendered}"
    destination = "${var.assets_path}/manifests/pod-checkpoint-installer.yaml"
  }

  # TLS Assets required by bootkube's temporary servers

  ## tls/apiserver.key
  provisioner "file" {
    content = "${tls_private_key.apiserver.private_key_pem}"
    destination = "${var.assets_path}/tls/apiserver.key"
  }

  ## tls/apiserver.crt
  provisioner "file" {
    content = "${tls_locally_signed_cert.apiserver.cert_pem}"
    destination = "${var.assets_path}/tls/apiserver.crt"
  }

  ## tls/ca.crt
  provisioner "file" {
    content = "${tls_self_signed_cert.kube-ca.cert_pem}"
    destination = "${var.assets_path}/tls/ca.crt"
  }

  ## tls/service-account.key
  provisioner "file" {
    content = "${tls_private_key.service-account.private_key_pem}"
    destination = "${var.assets_path}/tls/service-account.key"
  }

  ## tls/service-account.pub
  provisioner "file" {
    content = "${tls_private_key.service-account.public_key_pem}"
    destination = "${var.assets_path}/tls/service-account.pub"
  }

  # Execute bootkube as a systemd unit

  provisioner "file" "bootkube.service" {
    content = "${data.template_file.bootkube-service.rendered}"
    destination = "${var.assets_path}/bootkube.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv ${var.assets_path}/bootkube.service /etc/systemd/system/",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl start bootkube",
    ]
  }
}