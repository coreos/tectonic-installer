locals {
  // List of possible AZs for each type of subnet
  new_worker_subnet_azs = ["${coalescelist(keys(var.new_worker_subnet_configs), data.aws_availability_zones.azs.names)}"]
  new_master_subnet_azs = ["${coalescelist(keys(var.new_master_subnet_configs), data.aws_availability_zones.azs.names)}"]

  // How many AZs to create worker and master subnets in (always zero if external_vpc_mode)
  new_worker_az_count = "${ local.external_vpc_mode ? 0 : length(local.new_worker_subnet_azs) }"
  new_master_az_count = "${ local.external_vpc_mode ? 0 : length(local.new_master_subnet_azs) }"

  // Partition VPC cidr in half for master and worker generated cidr ranges independently of subnet counts
  // Generated master and worker subnets ranges will still be contiguous themselves
  // Example:
  //   new vpc_cidr      = 10.10.0.0/16 generated_cidrs=[ 10.10.0.0/20   , 10.10.16.0/20  ,... 10.10.240.0/20 ] max_subnets=16
  //   worker_cidr_range = 10.10.0.0/17 generated_cidrs=[ 10.10.0.0/20   , 10.10.16.0/20  ,... 10.10.112.0/20 ] max_subnets=8
  //   master_cidr_range = 10.10.0.0/17 generated_cidrs=[ 10.10.128.0/20 , 10.10.144.0/20 ,... 10.10.240.0/20 ] max_subnets=8
  // So, master and worker subnets can grow/shrink independently of each other if the VPC CIDR has free space left, making terraform apply a viable option for
  // changing subnet counts, AZ associations and CIDR- at least at the AWS VPC networking level.

  // jira ticket link for more background: https://coreosdev.atlassian.net/browse/INST-539
  new_worker_cidr_range = "${cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block,1,1)}"
  new_master_cidr_range = "${cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block,1,0)}"
}

resource "aws_vpc" "new_vpc" {
  count                = "${local.external_vpc_mode ? 0 : 1}"
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
      "Name", "${var.cluster_name}-vpc",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"
}
