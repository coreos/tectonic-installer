provider "aws" {
  region  = "${var.tectonic_aws_region}"
  profile = "${var.tectonic_aws_profile}"
  version = "1.8.0"

  assume_role {
    role_arn     = "${var.tectonic_aws_installer_role == "" ? "" : "${var.tectonic_aws_installer_role}"}"
    session_name = "TECTONIC_INSTALLER_${var.tectonic_cluster_name}"
  }
}

resource "aws_autoscaling_group" "master-bootstrap" {
  name                 = "${var.tectonic_cluster_name}-master-bootstrap"
  desired_capacity     = "0"
  max_size             = "0"
  min_size             = "0"
  launch_configuration = "${local.aws_launch_configuration_master_bootstrap}"
  vpc_zone_identifier  = ["${local.subnet_ids_masters}"]

  load_balancers = ["${local.aws_lbs_masters}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.tectonic_cluster_name}-master"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.tectonic_cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "tectonicClusterID"
      value               = "${local.cluster_id}"
      propagate_at_launch = true
    },
    "${var.tectonic_autoscaling_group_extra_tags}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}
