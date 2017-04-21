data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "../../modules/aws/vpc"

  cidr_block   = "${var.tectonic_aws_vpc_cidr_block}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_vpc_id         = "${var.tectonic_aws_external_vpc_id}"
  external_master_subnets = ["${compact(var.tectonic_aws_external_master_subnet_ids)}"]
  external_worker_subnets = ["${compact(var.tectonic_aws_external_worker_subnet_ids)}"]
  extra_tags              = "${var.tectonic_aws_extra_tags}"
  enable_etcd_sg          = "${length(compact(var.tectonic_etcd_servers)) == 0 ? 1 : 0}"

  # VPC layout settings.
  #
  # The following parameters control the layout of the VPC accross availability zones.
  # Two modes are available:
  # A. Explicitly configure a list of AZs + associated subnet CIDRs
  # B. Let the module calculate subnets accross a set number of AZs
  #
  # To enable mode A, make sure "tectonic_aws_az_count" variable IS NOT SET to any value 
  # and instead configure a set of AZs + CIDRs for masters and workers using the
  # "tectonic_aws_master_custom_subnets" and "tectonic_aws_worker_custom_subnets" variables.
  #
  # To enable mode B, make sure that "tectonic_aws_master_custom_subnets" and "tectonic_aws_worker_custom_subnets" 
  # ARE NOT SET. Instead, set the desired number of VPC AZs using "tectonic_aws_az_count" variable.

  # These counts could be deducted by length(keys(var.tectonic_aws_master_custom_subnets)) 
  # but there is a restriction on passing computed values as counts. This approach works around that.
  master_az_count = "${var.tectonic_aws_az_count == "" ? "${length(keys(var.tectonic_aws_master_custom_subnets))}" : var.tectonic_aws_az_count}"
  worker_az_count = "${var.tectonic_aws_az_count == "" ? "${length(keys(var.tectonic_aws_worker_custom_subnets))}" : var.tectonic_aws_az_count}"
  # The appending of the "padding" element is required as workaround since the function
  # element() won't work on empty lists. See https://github.com/hashicorp/terraform/issues/11210
  master_subnets = "${concat(values(var.tectonic_aws_master_custom_subnets),list("padding"))}"
  worker_subnets = "${concat(values(var.tectonic_aws_worker_custom_subnets),list("padding"))}"
  # The split() / join() trick works around the limitation of tenrary operator expressions 
  # only being able to return strings.
  master_azs = ["${ split("|", "${length(keys(var.tectonic_aws_master_custom_subnets))}" > 0 ?
    join("|", keys(var.tectonic_aws_master_custom_subnets)) :
    join("|", data.aws_availability_zones.azs.names)
  )}"]
  worker_azs = ["${ split("|", "${length(keys(var.tectonic_aws_worker_custom_subnets))}" > 0 ?
    join("|", keys(var.tectonic_aws_worker_custom_subnets)) :
    join("|", data.aws_availability_zones.azs.names)
  )}"]
}

module "etcd" {
  source = "../../modules/aws/etcd"

  instance_count = "${var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : var.tectonic_aws_az_count == 5 ? 5 : 3}"
  az_count       = "${length(data.aws_availability_zones.azs.names)}"
  ec2_type       = "${var.tectonic_aws_etcd_ec2_type}"
  sg_ids         = ["${module.vpc.etcd_sg_id}"]

  ssh_key         = "${var.tectonic_aws_ssh_key}"
  cl_channel      = "${var.tectonic_cl_channel}"
  container_image = "${var.tectonic_container_images["etcd"]}"

  subnets = ["${module.vpc.worker_subnet_ids}"]

  dns_zone_id  = "${aws_route53_zone.tectonic-int.zone_id}"
  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  external_endpoints = ["${compact(var.tectonic_etcd_servers)}"]
  extra_tags         = "${var.tectonic_aws_extra_tags}"

  root_volume_type = "${var.tectonic_aws_etcd_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_etcd_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_etcd_root_volume_iops}"
}

module "ignition-masters" {
  source = "../../modules/aws/ignition"

  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  kube_dns_service_ip       = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints            = ["${module.etcd.endpoints}"]
  etcd_gateway_enabled      = "${module.bootkube.etcd_gateway_enabled}"
  kubeconfig_s3_location    = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location        = "${aws_s3_bucket_object.tectonic-assets.bucket}/${aws_s3_bucket_object.tectonic-assets.key}"
  container_images          = "${var.tectonic_container_images}"
  bootkube_service          = "${module.bootkube.systemd_service}"
  tectonic_service          = "${module.tectonic.systemd_service}"
  tectonic_service_disabled = "${var.tectonic_vanilla_k8s}"
}

module "masters" {
  source = "../../modules/aws/master-asg"

  instance_count = "${var.tectonic_master_count}"
  ec2_type       = "${var.tectonic_aws_master_ec2_type}"
  cluster_name   = "${var.tectonic_cluster_name}"

  subnet_ids = ["${module.vpc.master_subnet_ids}"]

  master_sg_ids  = ["${module.vpc.master_sg_id}"]
  api_sg_ids     = ["${module.vpc.api_sg_id}"]
  console_sg_ids = ["${module.vpc.console_sg_id}"]

  ssh_key    = "${var.tectonic_aws_ssh_key}"
  cl_channel = "${var.tectonic_cl_channel}"
  user_data  = "${module.ignition-masters.ignition}"

  internal_zone_id             = "${aws_route53_zone.tectonic-int.zone_id}"
  external_zone_id             = "${join("", data.aws_route53_zone.tectonic-ext.*.zone_id)}"
  base_domain                  = "${var.tectonic_base_domain}"
  public_vpc                   = "${var.tectonic_aws_external_vpc_public}"
  extra_tags                   = "${var.tectonic_aws_extra_tags}"
  autoscaling_group_extra_tags = "${var.tectonic_autoscaling_group_extra_tags}"
  custom_dns_name              = "${var.tectonic_dns_name}"

  root_volume_type = "${var.tectonic_aws_master_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_master_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_master_root_volume_iops}"
}

module "ignition-workers" {
  source = "../../modules/aws/ignition"

  kubelet_node_label     = "node-role.kubernetes.io/node"
  kubelet_node_taints    = ""
  kube_dns_service_ip    = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints         = ["${module.etcd.endpoints}"]
  kubeconfig_s3_location = "${aws_s3_bucket_object.kubeconfig.bucket}/${aws_s3_bucket_object.kubeconfig.key}"
  assets_s3_location     = ""
  container_images       = "${var.tectonic_container_images}"
  bootkube_service       = ""
  tectonic_service       = ""
}

module "workers" {
  source = "../../modules/aws/worker-asg"

  instance_count = "${var.tectonic_worker_count}"
  ec2_type       = "${var.tectonic_aws_worker_ec2_type}"
  cluster_name   = "${var.tectonic_cluster_name}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.worker_subnet_ids}"]
  sg_ids     = ["${module.vpc.worker_sg_id}"]

  ssh_key                      = "${var.tectonic_aws_ssh_key}"
  cl_channel                   = "${var.tectonic_cl_channel}"
  user_data                    = "${module.ignition-workers.ignition}"
  extra_tags                   = "${var.tectonic_aws_extra_tags}"
  autoscaling_group_extra_tags = "${var.tectonic_autoscaling_group_extra_tags}"

  root_volume_type = "${var.tectonic_aws_master_root_volume_type}"
  root_volume_size = "${var.tectonic_aws_master_root_volume_size}"
  root_volume_iops = "${var.tectonic_aws_master_root_volume_iops}"
}
