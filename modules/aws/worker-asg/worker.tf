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

resource "aws_launch_configuration" "worker_conf" {
  instance_type        = "${var.ec2_type}"
  image_id             = "${data.aws_ami.coreos_ami.image_id}"
  name_prefix          = "${var.cluster_name}-worker-"
  key_name             = "${var.ssh_key}"
  security_groups      = ["${var.sg_ids}"]
  iam_instance_profile = "${aws_iam_instance_profile.worker_profile.arn}"
  user_data            = "${var.user_data}"
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
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 100}"
  }
}

resource "aws_autoscaling_group" "workers" {
  name                 = "${var.cluster_name}-workers"
  desired_capacity     = "${var.instance_count}"
  max_size             = "${var.instance_count * 3}"
  min_size             = "1"
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

resource "spotinst_aws_group" "workers" {
  name        = "workers-group"
  description = "created by Terraform"
  product     = "Linux/UNIX"
  count       = "${var.use_spotinst == true ? var.subnet_qty : 0}"

  capacity {
    target  = "${var.spot_capacity_target}"
    minimum = "${var.spot_capacity_min}"
    maximum = "${var.spot_capacity_max}"
  }

  # TODO: Is this default sensible? Should we parametize instead?
  strategy {
    risk = 100
  }

  # TODO: Are these defaults sensible? Should we parametize instead?
  scheduled_task {
    task_type             = "scale"
    cron_expression       = "0 5 * * 0-4"
    scale_target_capacity = 1
  }

  scheduled_task {
    task_type = "backup_ami"
    frequency = "hourly"
  }

  instance_types {
    ondemand = "${var.ec2_type}"

    # TODO: Should we parametize this? How do we ensure a compatible instance type is chosen? Should we just chose some defaults?
    spot = [
      "m3.large",
      "m4.large",
      "c3.large",
      "c4.large",
    ]
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
    user_data            = "${var.user_data}"
  }

  # TODO: Tags are BROKEN. Due to this structure, kubenetes.io key below will not be evaluated.
  # Until https://github.com/terraform-providers/terraform-provider-spotinst/issues/4 is resolved
  # this should NOT be merged. Once fixed, we must also include ${var.autoscaling_group_extra_tags}
  # in this tag list to ensure all additional user tags are created.
  tags {
    Name                                        = "${var.cluster_name}-worker"
    tectonicClusterID                           = "${var.cluster_id}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  scaling_up_policy {
    policy_name        = "Scaling Policy 1"
    metric_name        = "CPUUtilization"
    statistic          = "average"
    unit               = "percent"
    threshold          = 80
    adjustment         = 1
    namespace          = "AWS/EC2"
    period             = 300
    evaluation_periods = 2
    cooldown           = 300
  }

  scaling_down_policy {
    policy_name        = "Scaling Policy 2"
    metric_name        = "CPUUtilization"
    statistic          = "average"
    unit               = "percent"
    threshold          = 40
    adjustment         = 1
    namespace          = "AWS/EC2"
    period             = 300
    evaluation_periods = 2
    cooldown           = 300
  }
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.cluster_name}-worker-profile"

  role = "${var.worker_iam_role == "" ?
    join("|", aws_iam_role.worker_role.*.name) :
    join("|", data.aws_iam_role.worker_role.*.role_name)
  }"
}

data "aws_iam_role" "worker_role" {
  count     = "${var.worker_iam_role == "" ? 0 : 1}"
  role_name = "${var.worker_iam_role}"
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
