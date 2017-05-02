output "container-linux-install" {
  value = "${matchbox_profile.container-linux-install.name}"
}

output "cached-container-linux-install" {
  value = "${matchbox_profile.cached-container-linux-install.name}"
}

output "tectonic-controller" {
  value = "${matchbox_profile.tectonic-controller.name}"
}

output "tectonic-worker" {
  value = "${matchbox_profile.tectonic-worker.name}"
}
