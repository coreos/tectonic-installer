data "aws_availability_zones" "azs" {}

module "vpc" {
  source                       = "../../modules/aws/vpc"

  az_count     = "${var.tectonic_aws_az_count}"
  cidr_block   = "${var.tectonic_aws_vpc_cidr_block}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_vpc_id         = "${var.tectonic_aws_external_vpc_id}"
  external_master_subnets = []
  external_worker_subnets = []
}

module "etcd" {
  source = "../../modules/aws/etcd"

  instance_count = "${var.tectonic_aws_az_count == 5 ? 5 : 3}"
  az_count       = "${var.tectonic_aws_az_count}"
  ec2_type       = "${var.tectonic_aws_etcd_ec2_type}"

  ssh_key         = "${var.tectonic_aws_ssh_key}"
  cl_channel      = "${var.tectonic_cl_channel}"
  container_image = "${var.tectonic_container_images["etcd"]}"

  vpc_id  = "${module.vpc.vpc_id}"
  subnets = ["${module.vpc.worker_subnet_ids}"]

  dns_zone     = "${module.dns.int_zone_id}"
  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_endpoints = ["${var.tectonic_etcd_servers}"]
}

module "masters" {
  source = "../../modules/aws/master-asg"

  instance_count = "${var.tectonic_master_count}"
  ec2_type       = "${var.tectonic_aws_master_ec2_type}"

  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  vpc_id              = "${module.vpc.vpc_id}"
  subnet_ids          = ["${module.vpc.master_subnet_ids}"]
  extra_sg_ids        = ["${module.vpc.cluster_default_sg}"]
  kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints      = ["${formatlist("%s:2379", split(",", module.etcd.endpoints))}"]

  ssh_key          = "${var.tectonic_aws_ssh_key}"
  cl_channel       = "${var.tectonic_cl_channel}"
  container_images = "${var.tectonic_container_images}"

  kubeconfig_content = "${module.bootkube.kubeconfig}"
}

module "workers" {
  source = "../../modules/aws/worker-asg"

  instance_count = "${var.tectonic_worker_count}"
  ec2_type       = "${var.tectonic_aws_worker_ec2_type}"

  cluster_name = "${var.tectonic_cluster_name}"

  vpc_id              = "${module.vpc.vpc_id}"
  subnet_ids          = ["${module.vpc.worker_subnet_ids}"]
  extra_sg_ids        = ["${module.vpc.cluster_default_sg}"]
  kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints      = ["${formatlist("%s:2379", split(",", module.etcd.endpoints))}"]

  ssh_key          = "${var.tectonic_aws_ssh_key}"
  cl_channel       = "${var.tectonic_cl_channel}"
  container_images = "${var.tectonic_container_images}"

  kubeconfig_content = "${module.bootkube.kubeconfig}"
}

module "dns" {
  source = "../../modules/aws/dns"

  vpc_id               = "${module.vpc.vpc_id}"

  base_domain = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_dns_name}"

  console_elb          = "${module.masters.console-elb}"
  api_internal_elb     = "${module.masters.api-internal-elb}"
  api_external_elb     = "${module.masters.api-external-elb}"
}
