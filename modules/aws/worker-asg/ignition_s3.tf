data "ignition_config" "s3" {
  append {
    source = "${format("http://${var.cluster_name}-ncg.tectonic.kuwit.rocks/%s?profile=worker", "ignition")}"
  }

  files = ["${data.ignition_file.kubeconfig.id}"]
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${var.kubeconfig_content}"
  }
}
