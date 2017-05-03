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

resource "aws_cloudformation_stack" "master_autoscaling_group" {
  name = "${var.cluster_name}-master"

  # Health check grace period is 5 minutes.
  # Batch size is 1, and we pause 3 minutes between batches.
  # Plus 1 minute extra
  timeout_in_minutes = "${(var.instance_count * 5 * 3 ) + 1}"

  # Rolling back the master ASG likely won't improve things, so disable it.
  disable_rollback = true

  tags = "${merge(map(
      "Name", "${var.cluster_name}-cloudformation-master-asg",
      "KubernetesCluster", "${var.cluster_name}"
    ), var.extra_tags)}"

  template_body = <<EOF
{
  "Resources": {
    "AutoScalingGroup": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "VPCZoneIdentifier": ["${join("\",\"", var.subnet_ids)}"],
        "LaunchConfigurationName": "${aws_launch_configuration.master_conf.id}",
        "DesiredCapacity": "${var.instance_count}",
        "MinSize": "1",
        "MaxSize": "${var.instance_count * 3}",
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "ELB",
        "LoadBalancerNames": ["${aws_elb.api-internal.id}", "${join("",aws_elb.api-external.*.id)}", "${aws_elb.console.id}"],
        "HealthCheckGracePeriod": 300,
        "Tags": [
            {
                "Key": "Name",
                "Value": "${var.cluster_name}-master",
                "PropagateAtLaunch": true
            },
            {
                "Key": "KubernetesCluster",
                "Value": "${var.cluster_name}",
                "PropagateAtLaunch": true
            }
        ]
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "${var.instance_count}",
          "MaxBatchSize": "1",
          "PauseTime": "PT3M",
          "WaitOnResourceSignals": false
        }
      }
    }
  },
  "Outputs": {
    "AsgName": {
      "Description": "The name of the auto scaling group",
      "Value": {
        "Ref": "AutoScalingGroup"
      }
    },
    "StackName": {
      "Description": "The name of the auto scaling group",
      "Value": {
        "Ref": "AWS::StackName"
      }
    }
  }
}
EOF

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
  iam_instance_profile        = "${aws_iam_instance_profile.master_profile.arn}"
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
    iops        = "${var.root_volume_iops}"
  }
}

resource "aws_iam_instance_profile" "master_profile" {
  name = "${var.cluster_name}-master-profile"
  role = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_role" "master_role" {
  name = "${var.cluster_name}-master-role"
  path = "/"

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
  name = "${var.cluster_name}_master_policy"
  role = "${aws_iam_role.master_role.id}"

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
    },
    {
      "Action" : [
        "cloudformation:DescribeStackResource",
        "cloudformation:SignalResource"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
