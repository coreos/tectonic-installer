data "template_file" "cloud_provider_config" {
  template = <<EOF
[global]
multizone = true
EOF

  vars {}
}

output "cloud_provider" {
  value = "${var.enabled ? "gce" : ""}"
}

output "cloud_provider_config" {
  value = "${var.enabled ? "${data.template_file.cloud_provider_config.rendered}" : ""}"
}

output "network_plugin" {
  value = "${var.enabled ? "kubenet" : "cni"}"
}

output "hostname_override_cmd" {
  value = "${var.enabled ? "--hostname-override=$${NODENAME}" : ""}"
}
