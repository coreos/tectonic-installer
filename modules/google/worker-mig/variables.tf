/*
Copyright 2017 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

variable "cl_channel" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "zone_list" {
  type = "list"
}

variable "max_workers" {
  type = "string"
}

variable "machine_type" {
  type = "string"
}

variable "worker_targetpool_self_link" {
  type = "string"
}

variable "worker_subnetwork_name" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "base_domain" {
  type        = "string"
  description = "Domain on which the ELB records will be created"
}

variable "custom_dns_name" {
  type        = "string"
  default     = ""
  description = "DNS prefix used to construct the console and API server endpoints."
}

variable "disk_type" {
  type        = "string"
  description = "The type of volume for the root block device."
}

variable "disk_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device."
}

# vim: ts=2:sw=2:sts=2:et:ai
