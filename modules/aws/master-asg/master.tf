data "aws_ami" "coreos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-${var.cl_channel}-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["595879546273"]
  }
}

resource "aws_autoscaling_group" "masters" {
  name                 = "${var.cluster_name}-masters"
  desired_capacity     = "${var.instance_count}"
  max_size             = "${var.instance_count * 3}"
  min_size             = "1"
  launch_configuration = "${aws_launch_configuration.master_conf.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  load_balancers = ["${aws_elb.api-internal.id}", "${join("",aws_elb.api-external.*.id)}", "${aws_elb.console.id}"]

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

resource "aws_launch_configuration" "master_conf" {
  instance_type               = "${var.ec2_type}"
  image_id                    = "${data.aws_ami.coreos_ami.image_id}"
  name_prefix                 = "${var.cluster_name}-master-"
  key_name                    = "${var.ssh_key}"
  security_groups             = ["${var.master_sg_ids}"]
  iam_instance_profile        = "${coalesce(var.external_master_arn,join("", aws_iam_instance_profile.master_profile.*.arn))}"
  associate_public_ip_address = "${var.public_vpc}"
  user_data                   = "${var.user_data}"

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

resource "aws_iam_instance_profile" "master_profile" {
  count = "${var.external_master_arn == "" ? 1 : 0}"
  name  = "${var.cluster_name}-master-profile"
  role  = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_role" "master_role" {
  count = "${var.external_master_arn == "" ? 1 : 0}"
  name  = "${var.cluster_name}-master-role"
  path  = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "master_policy" {
  count = "${var.external_master_arn == "" ? 1 : 0}"
  name  = "${var.cluster_name}_master_policy"
  role  = "${aws_iam_role.master_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "s3:GetObject",
        "s3:HeadObject",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
