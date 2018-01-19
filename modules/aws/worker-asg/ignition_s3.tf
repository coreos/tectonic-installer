data "ignition_config" "s3" {
  replace {
    source = "${format("http://${var.cluster_name}-ncg.tectonic.kuwit.rocks/%s?profile=worker", "ignition")}"
  }
}
