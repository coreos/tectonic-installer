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

resource "aws_cloudformation_stack" "workers_autoscaling_group" {
  name = "${var.cluster_name}-workers"

  # Health check grace period is 2 minutes.
  # Batch size is 2, and we pause 3 minutes between batches.
  # Plus 1 minute extra
  timeout_in_minutes = "${((var.instance_count/2) * 2 * 3 ) + 1}"

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
        "LaunchConfigurationName": "${aws_launch_configuration.worker_conf.id}",
        "DesiredCapacity": "${var.instance_count}",
        "MinSize": "1",
        "MaxSize": "${var.instance_count * 3}",
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "EC2",
        "HealthCheckGracePeriod": 120,
        "Tags": [
            {
                "Key": "Name",
                "Value": "${var.cluster_name}-worker",
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
          "MaxBatchSize": "2",
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

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.cluster_name}-worker-profile"
  role = "${aws_iam_role.worker_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "worker_role" {
  name = "${var.cluster_name}-worker-role"
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${var.cluster_name}_worker_policy"
  role = "${aws_iam_role.worker_role.id}"

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

  lifecycle {
    create_before_destroy = true
  }
}
