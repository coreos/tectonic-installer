resource "aws_autoscaling_group" "workers" {
  depends_on           = ["aws_route53_record.ngc_internal"]
  name                 = "${var.tectonic_cluster_name}-workers"
  desired_capacity     = "${var.tectonic_worker_count}"
  max_size             = "${var.tectonic_worker_count * 3}"
  min_size             = "${var.tectonic_worker_count}"
  launch_configuration = "${local.aws_launch_configuration_workers}"
  vpc_zone_identifier  = ["${local.subnet_ids_workers}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.tectonic_cluster_name}-worker"
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
  ]

  //    "${var.autoscaling_group_extra_tags}",

  lifecycle {
    create_before_destroy = true
  }
}

//resource "aws_autoscaling_attachment" "workers" {
//  count = "${length(local.aws_lbs_workers)}"
//
//  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
//  elb                    = "${local.aws_lbs_workers[count.index]}"
//}
