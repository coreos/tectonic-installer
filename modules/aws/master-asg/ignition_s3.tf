resource "aws_s3_bucket_object" "ignition_master" {
  bucket  = "${var.s3_bucket}"
  key     = "ignition"
  content = "${data.ignition_config.main.rendered}"
  acl     = "public-read"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "${var.cluster_name}-ignition-master",
      "KubernetesCluster", "${var.cluster_name}",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"
}

data "aws_region" "region" {
  current = true
}

data "ignition_config" "s3" {
  replace {
    source = "http://${var.cluster_name}-ncg.${var.base_domain}/ignition?profile=controller"
  }
}
