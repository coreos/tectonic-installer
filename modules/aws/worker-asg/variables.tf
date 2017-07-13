variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "cl_channel" {
  type = "string"
}

variable "cluster_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "subnet_azs" {
  type        = "list"
  description = "Correlated azs for each subnet_id."
}

variable "subnet_qty" {
  type        = "string"
  description = "Quantity of subnets used for calculating spotinst count."
  default     = 0
}

variable "sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied."
}

variable "user_data" {
  type        = "string"
  description = "User-data content used to boot the instances"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "autoscaling_group_extra_tags" {
  description = "Extra AWS tags to be applied to created autoscaling group resources."
  type        = "list"
  default     = []
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume for the root block device."
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device."
}

variable "root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device."
}

variable "worker_iam_role" {
  type        = "string"
  default     = ""
  description = "IAM role to use for the instance profiles of worker nodes."
}

variable "use_spotinst" {
  type        = "string"
  default     = "false"
  description = "When true, sets up spotinst fleet for workers, rather than using ASGs."
}

variable "spot_capacity_target" {
  type        = "string"
  default     = "0"
  description = "Number of instances you'd like Spotinst to target."
}

variable "spot_capacity_min" {
  type        = "string"
  default     = "0"
  description = "Number of instances you'd like Spotinst to run at minimum."
}

variable "spot_capacity_max" {
  type        = "string"
  default     = "0"
  description = "Number of instances you'd like Spotinst to run at maximum."
}
