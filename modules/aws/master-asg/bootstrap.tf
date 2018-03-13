resource "aws_autoscaling_group" "master-bootstrap" {
  name                 = "${var.cluster_name}-master-bootstrap"
  desired_capacity     = "1"
  max_size             = "1"
  min_size             = "1"
  launch_configuration = "${aws_launch_configuration.master_bootstrap_conf.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  load_balancers = ["${var.aws_lbs}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-master"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "tectonicClusterID"
      value               = "${var.cluster_id}"
      propagate_at_launch = true
    },
    "${var.autoscaling_group_extra_tags}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master_bootstrap_conf" {
  instance_type               = "${var.ec2_type}"
  image_id                    = "${coalesce(var.ec2_ami, data.aws_ami.coreos_ami.image_id)}"
  name_prefix                 = "${var.cluster_name}-master-"
  key_name                    = "${var.ssh_key}"
  security_groups             = ["${var.master_sg_ids}"]
  iam_instance_profile        = "${aws_iam_instance_profile.master_profile.arn}"
  associate_public_ip_address = "${var.public_endpoints}"
  user_data                   = "${data.ignition_config.s3_master_bootstrap.rendered}"

  lifecycle {
    create_before_destroy = true

    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["image_id"]
  }

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
  }
}

data "ignition_config" "s3_master_bootstrap" {
  append {
    source = "${format("s3://%s/ign/v1/role/master", var.s3_bucket)}"
  }

  files = ["${data.ignition_file.kubelet_master_kubeconfig.id}"]
}
