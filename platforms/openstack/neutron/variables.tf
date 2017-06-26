variable "tectonic_openstack_neutron_config_version" {
  description = <<EOF
(internal) This declares the version of the OpenStack Neutron configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

variable "tectonic_openstack_master_flavor_id" {
  type = "string"

  description = <<EOF
The master flavor ID as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.
EOF
}

variable "tectonic_openstack_worker_flavor_id" {
  type = "string"

  description = <<EOF
The worker flavor ID as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.
EOF
}

variable "tectonic_openstack_etcd_flavor_id" {
  type = "string"

  description = <<EOF
(optional) The etcd flavor ID as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.
Needs to be set if not using experimental self-hosted mode.

Note: If `tectonic_experimental` is set to `true` this variable has no effect, because the cluster doesn't use dedicated etcd nodes.
EOF
}

variable "tectonic_openstack_image_id" {
  type = "string"

  description = <<EOF
The image ID as given in `openstack image list`. Specifies the OS image of the VM.
EOF
}

variable "tectonic_openstack_external_gateway_id" {
  type = "string"

  description = <<EOF
The ID of the network to be used as the external internet gateway as given in `openstack network list`.
EOF
}

variable "tectonic_openstack_floatingip_pool" {
  type    = "string"
  default = "public"

  description = <<EOF
The name name of the floating IP pool
as given in `openstack floating ip list`.
This pool will be used to assign floating IPs to worker and master nodes.
EOF
}

variable "tectonic_openstack_subnet_cidr" {
  type    = "string"
  default = "192.168.1.0/24"

  description = <<EOF
The subnet CIDR for the master/worker/etcd compute nodes.
This CIDR will also be assigned to the created the OpenStack subnet resource.
EOF
}

variable "tectonic_openstack_dns_nameservers" {
  type    = "list"
  default = []

  description = <<EOF
The DNS servers assigned to the generated OpenStack subnet resource.
EOF
}
