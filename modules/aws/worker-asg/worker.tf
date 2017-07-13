data "aws_ami" "coreos_ami" {
  filter {
    name   = "name"
    values = ["CoreOS-${var.container_linux_channel}-${var.container_linux_version}-*"]
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

resource "aws_launch_configuration" "worker_conf" {
  instance_type        = "${var.ec2_type}"
  image_id             = "${data.aws_ami.coreos_ami.image_id}"
  name_prefix          = "${var.cluster_name}-worker-"
  key_name             = "${var.ssh_key}"
  security_groups      = ["${var.sg_ids}"]
  iam_instance_profile = "${aws_iam_instance_profile.worker_profile.arn}"
  user_data            = "${data.ignition_config.main.rendered}"
  count                = "${var.use_spotinst == true ? 0 : 1}"

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

resource "aws_autoscaling_group" "workers" {
  name                 = "${var.cluster_name}-workers"
  desired_capacity     = "${var.instance_count}"
  max_size             = "${var.instance_count * 3}"
  min_size             = "${var.instance_count}"
  launch_configuration = "${aws_launch_configuration.worker_conf.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  count                = "${var.use_spotinst == true ? 0 : 1}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-worker"
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

resource "aws_autoscaling_attachment" "workers" {
  count = "${var.use_spotinst == true ? 0 : length(var.load_balancers)}"

  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
  elb                    = "${var.load_balancers[count.index]}"
}

resource "spotinst_aws_group" "workers" {
  name        = "${var.spot_group_prefix}-${element(var.subnet_azs, count.index)}-${element(var.subnet_ids, count.index)}-workers"
  description = "created by Terraform"
  product     = "Linux/UNIX"
  count       = "${var.use_spotinst == true ? var.subnet_qty : 0}"

  capacity {
    target  = "${var.spot_capacity_target}"
    minimum = "${var.spot_capacity_min}"
    maximum = "${var.spot_capacity_max}"
  }

  strategy {
    risk                 = "${var.spot_strategy_risk}"
    draining_timeout     = "${var.spot_strategy_draining_timeout}"
    availability_vs_cost = "${var.spot_avail_vs_cost}"
    fallback_to_ondemand = "${var.spot_fallback_to_ondemand}"
  }

  instance_types {
    ondemand = "${var.ec2_type}"
    spot     = "${var.spot_instance_types}"
  }

  availability_zone {
    name      = "${element(var.subnet_azs, count.index)}"
    subnet_id = "${element(var.subnet_ids, count.index)}"
  }

  launch_specification {
    monitoring           = false
    image_id             = "${data.aws_ami.coreos_ami.image_id}"
    key_pair             = "${var.ssh_key}"
    security_group_ids   = ["${var.sg_ids}"]
    iam_instance_profile = "${aws_iam_instance_profile.worker_profile.arn}"
    user_data            = "${data.ignition_config.main.rendered}"
  }

  ebs_block_device {
    # Setting the device_name to /dev/xvda ensures this setting is for the root volume
    device_name = "/dev/xvda"
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
  }

  tags_kv = [
    {
      key   = "Name"
      value = "${var.cluster_name}-worker"
    },
    {
      key   = "kubernetes.io/cluster/${var.cluster_name}"
      value = "owned"
    },
    {
      key   = "tectonicClusterID"
      value = "${var.cluster_id}"
    },
    "${var.elastic_group_extra_tags}",
  ]

  # Since autoscalers and such will constantly alter capacity, ignore this here to prevent
  # terraform apply from altering.
  lifecycle {
    ignore_changes = ["capacity"]
  }
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.cluster_name}-worker-profile"

  role = "${var.worker_iam_role == "" ?
    join("|", aws_iam_role.worker_role.*.name) :
    join("|", data.aws_iam_role.worker_role.*.name)
  }"
}

data "aws_iam_role" "worker_role" {
  count = "${var.worker_iam_role == "" ? 0 : 1}"
  name  = "${var.worker_iam_role}"
}

resource "aws_iam_role" "worker_role" {
  count = "${var.worker_iam_role == "" ? 1 : 0}"
  name  = "${var.cluster_name}-worker-role"
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

resource "aws_iam_role_policy" "worker_policy" {
  count = "${var.worker_iam_role == "" ? 1 : 0}"
  name  = "${var.cluster_name}_worker_policy"
  role  = "${aws_iam_role.worker_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
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
        "s3:GetObject"
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
