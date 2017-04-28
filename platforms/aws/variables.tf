variable "tectonic_aws_config_version" {
  description = <<EOF
(internal) This declares the version of the AWS configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

variable "tectonic_aws_ssh_key" {
  type        = "string"
  description = "Name of an SSH key located within the AWS region. Example: coreos-user."
}

variable "tectonic_aws_master_ec2_type" {
  type        = "string"
  description = "Instance size for the master node(s). Example: `t2.medium`."
  default     = "t2.medium"
}

variable "tectonic_aws_worker_ec2_type" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `t2.medium`."
  default     = "t2.medium"
}

variable "tectonic_aws_etcd_ec2_type" {
  type        = "string"
  description = "Instance size for the etcd node(s). Example: `t2.medium`."
  default     = "t2.medium"
}

variable "tectonic_aws_vpc_cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"

  description = <<EOF
Block of IP addresses used by the VPC.
This should not overlap with any other networks, such as a private datacenter connected via Direct Connect.
EOF
}

variable "tectonic_aws_az_count" {
  type    = "string"
  default = ""

  description = <<EOF
Number of Availability Zones your EC2 instances will be deployed across.
This should be less than or equal to the total number available in the region. 
Be aware that some regions only have 2.
If set worker and master subnet CIDRs are calculated automatically.
Note that this must be unset if availability zones CIDRs are configured explicitely using `tectonic_aws_master_custom_subnets` and `tectonic_aws_worker_custom_subnets`.
EOF
}

variable "tectonic_aws_external_vpc_id" {
  type = "string"

  description = <<EOF
(optional) ID of an existing VPC to launch nodes into.
If unset a new VPC is created.
Example: `vpc-123456`
EOF

  default = ""
}

variable "tectonic_aws_external_vpc_public" {
  default = true

  description = <<EOF
If set to true, create public facing ingress resources (ELB, A-records).
If set to false, a "private" cluster will be created with an internal ELB only.
EOF
}

variable "tectonic_aws_external_master_subnet_ids" {
  type = "list"

  description = <<EOF
(optional) List of subnet IDs within an existing VPC to deploy master nodes into.
Required to use an existing VPC and the list must match the AZ count.
Example: `["subnet-111111", "subnet-222222", "subnet-333333"]`
EOF

  default = [""]
}

variable "tectonic_aws_external_worker_subnet_ids" {
  type = "list"

  description = <<EOF
(optional) List of subnet IDs within an existing VPC to deploy worker nodes into.
Required to use an existing VPC and the list must match the AZ count.
Example: `["subnet-111111", "subnet-222222", "subnet-333333"]`
EOF

  default = [""]
}

variable "tectonic_aws_extra_tags" {
  type        = "map"
  description = "(optional) Extra AWS tags to be applied to created resources."
  default     = {}
}

variable "tectonic_autoscaling_group_extra_tags" {
  type    = "list"
  default = []

  description = <<EOF
(optional) Extra AWS tags to be applied to created autoscaling group resources.
This is a list of maps having the keys `key`, `value` and `propagate_at_launch`.
Example: `[ { key = "foo", value = "bar", propagate_at_launch = true } ]`
EOF
}

variable "tectonic_dns_name" {
  type        = "string"
  default     = ""
  description = "(optional) DNS prefix used to construct the console and API server endpoints."
}

variable "tectonic_aws_etcd_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of etcd nodes."
}

variable "tectonic_aws_etcd_root_volume_size" {
  type        = "string"
  default     = "30"
  description = "The size of the volume in gigabytes for the root block device of etcd nodes."
}

variable "tectonic_aws_etcd_root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device of etcd nodes."
}

variable "tectonic_aws_master_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of master nodes."
}

variable "tectonic_aws_master_root_volume_size" {
  type        = "string"
  default     = "30"
  description = "The size of the volume in gigabytes for the root block device of master nodes."
}

variable "tectonic_aws_master_root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device of master nodes."
}

variable "tectonic_aws_worker_root_volume_type" {
  type        = "string"
  default     = "gp2"
  description = "The type of volume for the root block device of worker nodes."
}

variable "tectonic_aws_worker_root_volume_size" {
  type        = "string"
  default     = "30"
  description = "The size of the volume in gigabytes for the root block device of worker nodes."
}

variable "tectonic_aws_worker_root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device of worker nodes."
}

variable "tectonic_aws_master_custom_subnets" {
  type    = "map"
  default = {}

  description = <<EOF
(optional) This configures master availability zones and their corresponding subnet CIDRs directly.
Example: `{ eu-west-1a = "10.0.0.0/20", eu-west-1b = "10.0.16.0/20" }`
Note that `tectonic_aws_az_count` must be unset if this is specified.
EOF
}

variable "tectonic_aws_worker_custom_subnets" {
  type    = "map"
  default = {}

  description = <<EOF
(optional) This configures worker availability zones and their corresponding subnet CIDRs directly.
Example: `{ eu-west-1a = "10.0.64.0/20", eu-west-1b = "10.0.80.0/20" }`
Note that `tectonic_aws_az_count` must be unset if this is specified.
EOF
}
