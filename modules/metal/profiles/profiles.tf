// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  name   = "container-linux-install"
  kernel = "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded container_linux_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  name   = "cached-container-linux-install"
  kernel = "/assets/coreos/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"
}

// Tectonic Controller profile
resource "matchbox_profile" "tectonic-controller" {
  name                   = "tectonic-controller"
  container_linux_config = "${file("${path.module}/cl/tectonic-controller.yaml.tmpl")}"
}

// Tectonic Worker profile
resource "matchbox_profile" "tectonic-worker" {
  name                   = "tectonic-worker"
  container_linux_config = "${file("${path.module}/cl/tectonic-worker.yaml.tmpl")}"
}
