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

variable "tectonic_gcp_config_version" {
  description = <<EOF
This declares the version of the GCP configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

variable "tectonic_gcp_project_id" {
  type        = "string"
  default     = ""
  description = "The GCP project ID (string) to use."
}

variable "tectonic_gcp_credentials" {
  type        = "string"
  default     = ""
  description = "The GCP credentials to use, leave blank for GCE metadata"
}

variable "google_managedzone_name" {
  # not to be confused with tectonic_base_domain (the DNS compliant domain name)
  type        = "string"
  default     = "my-managed-zone"
  description = "GCP resource name of Cloud DNS ManagedZone - created outside of Tectonic"
}

variable "tectonic_dns_prefix_name" {
  type        = "string"
  default     = ""
  description = "DNS prefix used to construct the console and API server endpoints."
}

variable "tectonic_gcp_region" {
  type    = "string"
  default = "us-central1"
  description = "The GCP region to use. Some regions only have 2 zones."
}

variable "tectonic_gcp_zones" {
  type    = "list"
  default = ["us-central1-a", "us-central1-b"]
  description = "List of two or more zones to use from specified GCP region."
}

variable "tectonic_gcp_network_masters_cidr_range" {
  type    = "string"
  default = "10.10.0.0/16"
  description = "The CIDR range to use for the subnetwork for Masters."
}

variable "tectonic_gcp_network_workers_cidr_range" {
  type    = "string"
  default = "10.11.0.0/16"
  description = "The CIDR range to use for the subnetwork for Workers."
}

variable "tectonic_gcp_network_etcd_cidr_range" {
  type    = "string"
  default = "10.12.0.0/16"
  description = "The CIDR range to use for the subnetwork for etcd."
}

variable "tectonic_gcp_network_etcd_loadbalancer_ip" {
  type    = "string"
  default = "10.12.0.2"
  description = "The private IP address to use for the internal etcd load-balancer. Must be a valid IP in the etcd_cidr_range."
}

variable "tectonic_masters_max" {
  type    = "string"
  default = "2"
  description = "Upper limit for auto-scaling, per zone."
}

variable "tectonic_workers_max" {
  type    = "string"
  default = "3"
  description = "Upper limit for auto-scaling, per zone."
}

variable "tectonic_etcd_nodes_max" {
  type    = "string"
  default = "2"
  description = "Upper limit for auto-scaling, per zone."
}

variable "tectonic_gcp_master_gce_type" {
  type        = "string"
  description = "Instance size for the master node(s). Example: `n1-standard-2`."
  default     = "n1-standard-2"
}

variable "tectonic_gcp_master_disktype" {
  type        = "string"
  default     = "pd-standard"
  description = "The type of disk (pd-standard or pd-ssd) for the master nodes."
}

variable "tectonic_gcp_master_disk_size" {
  type        = "string"
  default     = "30"
  description = "The size of the disk in gigabytes for the root block device of master nodes."
}

variable "tectonic_gcp_worker_gce_type" {
  type        = "string"
  description = "Instance size for the worker node(s). Example: `n1-standard-2`."
  default     = "n1-standard-2"
}

variable "tectonic_gcp_worker_disktype" {
  type        = "string"
  default     = "pd-standard"
  description = "The type of disk (pd-standard or pd-ssd) for the worker nodes."
}

variable "tectonic_gcp_worker_disk_size" {
  type        = "string"
  default     = "30"
  description = "The size of the disk in gigabytes for the root block device of worker nodes."
}

variable "tectonic_gcp_etcd_gce_type" {
  type        = "string"
  description = "Instance size for the etcd node(s). Example: `n1-standard-2`."
  default     = "n1-standard-2"
}

variable "tectonic_gcp_etcd_disktype" {
  type        = "string"
  default     = "pd-standard"
  description = "The type of disk (pd-standard or pd-ssd) for the etcd nodes."
}

variable "tectonic_gcp_etcd_disk_size" {
  type        = "string"
  default     = "30"
  description = "The size of the disk in gigabytes for the root block device of etcd nodes."
}

# vim: ts=2:sw=2:sts=2:et
