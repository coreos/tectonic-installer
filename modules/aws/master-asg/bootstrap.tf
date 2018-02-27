resource "aws_instance" "bootstrap_node" {
  ami = "${coalesce(var.ec2_ami, data.aws_ami.coreos_ami.image_id)}"

  iam_instance_profile = "${aws_iam_instance_profile.master_profile.name}"
  instance_type        = "${var.ec2_type}"
  key_name             = "${var.ssh_key}"
  subnet_id            = "${var.subnet_ids[0]}"
  user_data            = "${data.ignition_config.ncg_master.rendered}"

  vpc_security_group_ids = [
    "${var.master_sg_ids}",
  ]

  tags = "${merge(map(
      "Name", "${var.cluster_name}-bootstrap",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"

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

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.bootstrap_node.id}"
  allocation_id = "${var.eip_bootstrap_id}"
}

// Value of count cannot be computed https://github.com/hashicorp/terraform/issues/15172
// Maximun number of lb are 4. If less tf will create identical entries in state until 4
resource "aws_elb_attachment" "bootstrap_node" {
  count    = "4"
  elb      = "${element(var.aws_lbs, count.index)}"
  instance = "${aws_instance.bootstrap_node.id}"
}
