data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "../../modules/aws/vpc"

  az_count     = "${var.tectonic_aws_az_count}"
  cidr_block   = "${var.tectonic_aws_vpc_cidr_block}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_vpc_id         = "${var.tectonic_aws_external_vpc_id}"
  external_master_subnets = ["${compact(var.tectonic_aws_external_master_subnets)}"]
  external_worker_subnets = ["${compact(var.tectonic_aws_external_worker_subnets)}"]
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

  dns_zone_id  = "${aws_route53_zone.tectonic-int.zone_id}"
  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_endpoints = ["${compact(var.tectonic_etcd_servers)}"]
}

module "ignition-masters" {
  source = "../../modules/aws/ignition"

  kubelet_node_label     = "master=true"
  kube_dns_service_ip    = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints         = ["${module.etcd.endpoints}"]
  kubeconfig_s3_location = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location     = "${aws_s3_bucket_object.tectonic-assets.bucket}/${aws_s3_bucket_object.tectonic-assets.key}"
  container_images       = "${var.tectonic_container_images}"
}

module "masters" {
  source = "../../modules/aws/master-asg"

  instance_count = "${var.tectonic_master_count}"
  ec2_type       = "${var.tectonic_aws_master_ec2_type}"
  cluster_name   = "${var.tectonic_cluster_name}"

  vpc_id       = "${module.vpc.vpc_id}"
  subnet_ids   = ["${module.vpc.master_subnet_ids}"]
  extra_sg_ids = ["${module.vpc.cluster_default_sg}"]

  ssh_key    = "${var.tectonic_aws_ssh_key}"
  cl_channel = "${var.tectonic_cl_channel}"
  user_data  = "${module.ignition-masters.ignition}"

  internal_zone_id = "${aws_route53_zone.tectonic-int.zone_id}"
  external_zone_id = "${data.aws_route53_zone.tectonic-ext.zone_id}"
  base_domain      = "${var.tectonic_base_domain}"
}

module "ignition-workers" {
  source = "../../modules/aws/ignition"

  kubelet_node_label     = ""
  kube_dns_service_ip    = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints         = ["${module.etcd.endpoints}"]
  kubeconfig_s3_location = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location     = ""
  container_images       = "${var.tectonic_container_images}"
}

module "workers" {
  source = "../../modules/aws/worker-asg"

  instance_count = "${var.tectonic_worker_count}"
  ec2_type       = "${var.tectonic_aws_worker_ec2_type}"
  cluster_name   = "${var.tectonic_cluster_name}"

  vpc_id       = "${module.vpc.vpc_id}"
  subnet_ids   = ["${module.vpc.worker_subnet_ids}"]
  extra_sg_ids = ["${module.vpc.cluster_default_sg}"]

  ssh_key    = "${var.tectonic_aws_ssh_key}"
  cl_channel = "${var.tectonic_cl_channel}"
  user_data  = "${module.ignition-workers.ignition}"
}
