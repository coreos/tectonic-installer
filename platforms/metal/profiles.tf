// Create machine profiles
module "profiles" {
  source = "../../modules/metal/profiles"

  matchbox_http_endpoint  = "${var.tectonic_metal_matchbox_http_endpoint}"
  container_linux_version = "${var.tectonic_metal_cl_version}"
  container_linux_channel = "${var.tectonic_cl_channel}"
}
