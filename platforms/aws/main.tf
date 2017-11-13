provider "aws" {
  region = "${var.tectonic_aws_region}"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "../../modules/aws/vpc"

  cidr_block   = "${var.tectonic_aws_vpc_cidr_block}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_vpc_id         = "${var.tectonic_aws_external_vpc_id}"
  disable_s3_vpc_endpoint = "${var.tectonic_aws_disable_s3_vpc_endpoint}"

  external_master_subnet_ids = "${compact(var.tectonic_aws_external_master_subnet_ids)}"
  external_worker_subnet_ids = "${compact(var.tectonic_aws_external_worker_subnet_ids)}"

  cluster_id     = "${module.tectonic.cluster_id}"
  extra_tags     = "${var.tectonic_aws_extra_tags}"
  enable_etcd_sg = "${!var.tectonic_experimental && length(compact(var.tectonic_etcd_servers)) == 0 ? 1 : 0}"

  // empty map subnet_configs will have the vpc module creating subnets in all availabile AZs
  new_master_subnet_configs = "${var.tectonic_aws_master_custom_subnets}"
  new_worker_subnet_configs = "${var.tectonic_aws_worker_custom_subnets}"
}

module "etcd" {
  source = "../../modules/aws/etcd"

  instance_count = "${var.tectonic_experimental ? 0 : var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.aws_availability_zones.azs.names) == 5 ? 5 : 3}"
  ec2_type       = "${var.tectonic_aws_etcd_ec2_type}"
  sg_ids         = "${concat(var.tectonic_aws_etcd_extra_sg_ids, list(module.vpc.etcd_sg_id))}"

  ssh_key         = "${var.tectonic_aws_ssh_key}"
  cl_channel      = "${var.tectonic_cl_channel}"
  container_image = "${var.tectonic_container_images["etcd"]}"

  subnets = "${module.vpc.worker_subnet_ids}"

  dns_zone_id  = "${var.tectonic_aws_external_private_zone == "" ? join("", aws_route53_zone.tectonic_int.*.zone_id) : var.tectonic_aws_external_private_zone}"
  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_endpoints = "${compact(var.tectonic_etcd_servers)}"
  cluster_id         = "${module.tectonic.cluster_id}"
  extra_tags         = "${var.tectonic_aws_extra_tags}"

  root_volume_type = "${var.tectonic_aws_etcd_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_etcd_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_etcd_root_volume_iops}"

  dns_enabled = "${!var.tectonic_experimental && length(compact(var.tectonic_etcd_servers)) == 0}"
  tls_enabled = "${var.tectonic_etcd_tls_enabled}"

  tls_zip = "${module.bootkube.etcd_tls_zip}"
}

module "ignition_masters" {
  source = "../../modules/aws/ignition"

  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  kubelet_cni_bin_dir       = "${var.tectonic_calico_network_policy ? "/var/lib/cni/bin" : "" }"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubeconfig_s3_location    = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location        = "${aws_s3_bucket_object.tectonic_assets.bucket}/${aws_s3_bucket_object.tectonic_assets.key}"
  container_images          = "${var.tectonic_container_images}"
  bootkube_service          = "${module.bootkube.systemd_service}"
  tectonic_service          = "${module.tectonic.systemd_service}"
  tectonic_service_disabled = "${var.tectonic_vanilla_k8s}"
  cluster_name              = "${var.tectonic_cluster_name}"
  image_re                  = "${var.tectonic_image_re}"
  custom_cacertificates     = "${var.tectonic_custom_cacertificates}"

  rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
  rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

  registry_cache_image                = "${var.tectonic_registry_cache_image}"
  registry_cache_rkt_protocol         = "${var.tectonic_registry_cache_rkt_protocol}"
  registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"
}

module "masters" {
  source = "../../modules/aws/master-asg"

  instance_count  = "${var.tectonic_master_count}"
  ec2_type        = "${var.tectonic_aws_master_ec2_type}"
  cluster_name    = "${var.tectonic_cluster_name}"
  master_iam_role = "${var.tectonic_aws_master_iam_role_name}"

  subnet_ids = "${module.vpc.master_subnet_ids}"

  master_sg_ids  = "${concat(var.tectonic_aws_master_extra_sg_ids, list(module.vpc.master_sg_id))}"
  api_sg_ids     = ["${module.vpc.api_sg_id}"]
  console_sg_ids = ["${module.vpc.console_sg_id}"]

  ssh_key    = "${var.tectonic_aws_ssh_key}"
  cl_channel = "${var.tectonic_cl_channel}"
  user_data  = "${module.ignition_masters.ignition}"

  internal_zone_id             = "${var.tectonic_aws_external_private_zone == "" ? join("", aws_route53_zone.tectonic_int.*.zone_id) : var.tectonic_aws_external_private_zone}"
  external_zone_id             = "${join("", data.aws_route53_zone.tectonic_ext.*.zone_id)}"
  base_domain                  = "${var.tectonic_base_domain}"
  public_vpc                   = "${var.tectonic_aws_external_vpc_public}"
  cluster_id                   = "${module.tectonic.cluster_id}"
  extra_tags                   = "${var.tectonic_aws_extra_tags}"
  autoscaling_group_extra_tags = "${var.tectonic_autoscaling_group_extra_tags}"
  custom_dns_name              = "${var.tectonic_dns_name}"

  root_volume_type = "${var.tectonic_aws_master_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_master_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_master_root_volume_iops}"
}

module "ignition_workers" {
  source = "../../modules/aws/ignition"

  kubelet_node_label     = "node-role.kubernetes.io/node"
  kubelet_node_taints    = ""
  kubelet_cni_bin_dir    = "${var.tectonic_calico_network_policy ? "/var/lib/cni/bin" : "" }"
  kube_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
  kubeconfig_s3_location = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location     = ""
  container_images       = "${var.tectonic_container_images}"
  bootkube_service       = ""
  tectonic_service       = ""
  cluster_name           = ""
  image_re               = "${var.tectonic_image_re}"
  custom_cacertificates  = "${var.tectonic_custom_cacertificates}"

  rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
  rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

  registry_cache_image                = "${var.tectonic_registry_cache_image}"
  registry_cache_rkt_protocol         = "${var.tectonic_registry_cache_rkt_protocol}"
  registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"
}

module "workers" {
  source = "../../modules/aws/worker-asg"

  instance_count  = "${var.tectonic_worker_count}"
  ec2_type        = "${var.tectonic_aws_worker_ec2_type}"
  cluster_name    = "${var.tectonic_cluster_name}"
  worker_iam_role = "${var.tectonic_aws_worker_iam_role_name}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.worker_subnet_ids}"
  sg_ids     = "${concat(var.tectonic_aws_worker_extra_sg_ids, list(module.vpc.worker_sg_id))}"

  ssh_key                      = "${var.tectonic_aws_ssh_key}"
  cl_channel                   = "${var.tectonic_cl_channel}"
  user_data                    = "${module.ignition_workers.ignition}"
  cluster_id                   = "${module.tectonic.cluster_id}"
  extra_tags                   = "${var.tectonic_aws_extra_tags}"
  autoscaling_group_extra_tags = "${var.tectonic_autoscaling_group_extra_tags}"

  root_volume_type = "${var.tectonic_aws_worker_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_worker_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_worker_root_volume_iops}"
}
