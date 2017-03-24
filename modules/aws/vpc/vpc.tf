data "aws_availability_zones" "azs" {}

resource "aws_vpc" "new_vpc" {
  count = "${var.external_vpc_id == "" ? 0 : 1}"

  cidr_block = "${var.cidr_block}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name              = "${var.external_vpc_id == "" ? var.cluster_name : "${var.cluster_name}-side-effect"}"
    KubernetesCluster = "${var.external_vpc_id == "" ? var.cluster_name : "${var.cluster_name}-side-effect"}"
  }
}

data "aws_vpc" "cluster_vpc" {
  id = "${var.external_vpc_id == "" ? join(" ", aws_vpc.new_vpc.*.id) : var.external_vpc_id }"
}
