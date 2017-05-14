module "custom-caertificates" {
  source = "../../modules/field-customizations/custom-cacertificates"
  cacertificates = "${var.tectonic_custom_cacertificates}"
}


module "tectonic-registry-cache" {
  source = "../../modules/field-customizations/tectonic-registry-cache"
  enabled = "${tectonic_registry_cache_image != ""}"

  image_repo           = "${replace(tectonic_registry_cache_image, teconic_image_re, "$1")}"
  image_tag            = "${replace(tectonic_registry_cache_image, tectonic_image_re, "$2")}"
  rkt_image_protocol   = "${tectonic_registry_cache_rkt_protocol}"
  rkt_insecure_options = "${tecontic_registry_cache_rkt_insecure_options}"
}
