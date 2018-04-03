<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->
# Terraform variables
This document gives an overview of variables used in the Openstack/Neutron platform of the Tectonic SDK.

## Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| tectonic_openstack_disable_floatingip | Disable floating ip assignments for k8s nodes. Warning: Enabling this option removes direct internet access, which prevents NodePorts from working. | string | `false` |
| tectonic_openstack_dns_nameservers | The nameservers used by the nodes and the generated OpenStack subnet resource.<br><br>Example: `["8.8.8.8", "8.8.4.4"]` | list | `<list>` |
| tectonic_openstack_etcd_flavor_id | (optional) The flavor id for etcd instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_etcd_flavor_name or tectonic_openstack_etcd_flavor_id. Note: This value is ignored for self-hosted etcd. | string | `` |
| tectonic_openstack_etcd_flavor_name | (optional) The flavor name for etcd instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_etcd_flavor_name or tectonic_openstack_etcd_flavor_id. Note: This value is ignored for self-hosted etcd. | string | `` |
| tectonic_openstack_external_gateway_id | The ID of the network to be used as the external internet gateway as given in `openstack network list`. | string | - |
| tectonic_openstack_floatingip_pool | The name name of the floating IP pool as given in `openstack floating ip list`. This pool will be used to assign floating IPs to worker and master nodes. | string | `public` |
| tectonic_openstack_image_id | The image ID as given in `openstack image list`. Specifies the OS image of the VM.<br><br>Note: Set either tectonic_openstack_image_name or tectonic_openstack_image_id. | string | `` |
| tectonic_openstack_image_name | The image ID as given in `openstack image list`. Specifies the OS image of the VM.<br><br>Note: Set either tectonic_openstack_image_name or tectonic_openstack_image_id. | string | `` |
| tectonic_openstack_lb_provider | The name of a valid provider to provision the load balancer. This will depend on how your OpenStack environment is configured.<br><br>Common options are: octavia, haproxy, f5, brocade, etc.<br><br>Please look at the OpenStack documentation for more details: https://developer.openstack.org/api-ref/networking/v2/index.html?expanded=create-a-load-balancer-detail#lbaas-2-0-stable | string | `` |
| tectonic_openstack_master_flavor_id | The flavor id for master instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_master_flavor_name or tectonic_openstack_master_flavor_id. | string | `` |
| tectonic_openstack_master_flavor_name | The flavor name for master instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_master_flavor_name or tectonic_openstack_master_flavor_id. | string | `` |
| tectonic_openstack_neutron_config_version | (internal) This declares the version of the OpenStack Neutron configuration variables. It has no impact on generated assets but declares the version contract of the configuration. | string | `1.0` |
| tectonic_openstack_subnet_cidr | The subnet CIDR for the master/worker/etcd compute nodes. This CIDR will also be assigned to the created the OpenStack subnet resource. | string | `192.168.1.0/24` |
| tectonic_openstack_worker_flavor_id | The flavor id for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_worker_flavor_name or tectonic_openstack_worker_flavor_id. | string | `` |
| tectonic_openstack_worker_flavor_name | The flavor name for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.<br><br>Note: Set either tectonic_openstack_worker_flavor_name or tectonic_openstack_worker_flavor_id. | string | `` |
