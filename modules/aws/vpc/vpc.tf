data "aws_availability_zones" "azs" {}

resource "aws_vpc" "new_vpc" {
  # count                = "${length(var.external_vpc_id) > 0 ? 0 : 1}"
  #
  # We can't yet use the count gate here because of terraform issues:
  # https://github.com/hashicorp/hil/issues/50
  # https://github.com/hashicorp/terraform/issues/11566
  # This should be re-enabled when above issues are fixed.
  #
  cidr_block = "${var.cidr_block}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name              = "${var.external_vpc_id == "" ? var.cluster_name : "${var.cluster_name}-side-effect"}"
    KubernetesCluster = "${var.external_vpc_id == "" ? var.cluster_name : "${var.cluster_name}-side-effect"}"
  }
}

data "aws_vpc" "cluster_vpc" {
  id = "${var.external_vpc_id == "" ? aws_vpc.new_vpc.id : var.external_vpc_id }"
}
