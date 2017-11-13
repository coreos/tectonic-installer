locals {
  s3_bucket = "${element(split("/",var.kubeconfig_s3_location),0)}"
  modconfigs = ["${concat(
    module.tectonic-registry-cache.append_configs,
    module.custom-cacertificates.append_configs,
  )}"]

  url_fmt = "s3://${local.s3_bucket}/%s"
}

resource "aws_s3_bucket_object" "append_config" {
  count = "${length(local.modconfigs)}"
  bucket = "${local.s3_bucket}"
  content = "${local.modconfigs[count.index]}"
  key = "field_ignition/${sha1(local.modconfigs[count.index])}/config.json"
  content_encoding = "application/json"
  etag = "${md5(local.modconfigs[count.index])}"
}

module "tectonic-registry-cache" {
  source  = "../../../modules/field-customizations/tectonic-registry-cache"
  enabled = "${var.registry_cache_image != "" ? true : false}"

  image_repo           = "${replace(var.registry_cache_image, var.image_re, "$1")}"
  image_tag            = "${replace(var.registry_cache_image, var.image_re, "$2")}"
  rkt_image_protocol   = "${var.registry_cache_rkt_protocol}"
  rkt_insecure_options = "${var.registry_cache_rkt_insecure_options}"
}

module "custom-cacertificates" {
  source = "../../../modules/field-customizations/custom-cacertificates"

  // If zero length, module will have empty output (`enabled` flag equivalent)
  cacertificates = "${var.custom_cacertificates}"
}
