variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "container_linux_channel" {
  type = "string"
}

variable "container_linux_version" {
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

variable "load_balancers" {
  description = "List of ELBs to attach all worker instances to."
  type        = "list"
  default     = []
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

variable "elastic_group_extra_tags" {
  description = "Extra AWS tags to be applied to instances created from Spotinst elasticgroups."
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

variable "ign_s3_puller_id" {
  type = "string"
}

variable "use_spotinst" {
  type        = "string"
  default     = "false"
  description = "When true, sets up spotinst fleet for workers, rather than using ASGs."
}

variable "spot_group_prefix" {
  type        = "string"
  default     = ""
  description = "Prefix used for naming Spotinst Elasticgroups."
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

variable "spot_strategy_risk" {
  type        = "string"
  default     = "100"
  description = "The percentage of Spot instances that would spin up from the spot_capacity_target number"
}

variable "spot_strategy_draining_timeout" {
  type        = "string"
  default     = "600"
  description = "The time in seconds, the instance is allowed to run while detached from the ELB.  This is to allow the instance time to be drained from incoming TCP connections before terminating it, during a scale down operation."
}

variable "spot_instance_types" {
  description = "List of instance types Spotinst should consider when bidding."
  type        = "list"

  default = [
    "m3.large",
    "m4.large",
    "c3.large",
    "c4.large",
  ]
}

variable "spot_avail_vs_cost" {
  type = "string"

  description = "Sets Spotinst's cluster orientation. A setting used to specify what algorithm to use when purchasing spot instances.  https://help.spotinst.com/hc/en-us/articles/115003136565-Advanced-settings-General-Tab"
  default     = "balanced"
}

variable "spot_fallback_to_ondemand" {
  type        = "string"
  description = "When true, in the case of no available spot instances, this will enable the fallback to On-Demand instances."
  default     = "true"
}
