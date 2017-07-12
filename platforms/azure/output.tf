output "bootkube_ca_cert" {
  value = "${module.bootkube.ca_cert}"
}

output "bootkube_ca_key" {
  value = "${module.bootkube.ca_key}"
}

output "bootkube_ca_key_alg" {
  value = "${module.bootkube.ca_key_alg}"
}

output "bootkube_etcd_ca_crt_pem" {
  value = "${module.bootkube.etcd_ca_crt_pem}"
}

output "bootkube_etcd_client_crt_pem" {
  value = "${module.bootkube.etcd_client_crt_pem}"
}

output "bootkube_etcd_client_key_pem" {
  value = "${module.bootkube.etcd_client_key_pem}"
}

output "bootkube_etcd_peer_crt_pem" {
  value = "${module.bootkube.etcd_peer_crt_pem}"
}

output "bootkube_etcd_peer_key_pem" {
  value = "${module.bootkube.etcd_peer_key_pem}"
}

output "bootkube_etcd_server_crt_pem" {
  value = "${module.bootkube.etcd_server_crt_pem}"
}

output "bootkube_etcd_server_key_pem" {
  value = "${module.bootkube.etcd_server_key_pem}"
}

output "bootkube_id" {
  value = "${module.bootkube.id}"
}

output "bootkube_kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

output "bootkube_kube_dns_service_ip" {
  value = "${module.bootkube.kube_dns_service_ip}"
}

output "bootkube_systemd_service" {
  value = "${module.bootkube.systemd_service}"
}

output "cloud_provider_config" {
  value = "${jsonencode(data.null_data_source.cloud-provider.inputs)}"
}

output "etcd_node_names" {
  value = "${module.etcd.node_names}"
}

output "resource_group_name" {
  value = "${module.resource_group.name}"
}

output "tectonic_systemd_service" {
  value = "${module.tectonic.systemd_service}"
}

output "vnet_api_ip_addresses" {
  value = "${module.vnet.api_ip_addresses}"
}

output "vnet_console_ip_addresses" {
  value = "${module.vnet.console_ip_addresses}"
}

output "vnet_etcd_cidr" {
  value = "${module.vnet.etcd_cidr}"
}

output "vnet_etcd_endpoints" {
  value = "${module.vnet.etcd_endpoints}"
}

output "vnet_etcd_network_interface_ids" {
  value = "${module.vnet.etcd_network_interface_ids}"
}

output "vnet_master_ip_addresses" {
  value = "${module.vnet.master_private_ip_addresses}"
}

output "vnet_master_cidr" {
  value = "${module.vnet.master_cidr}"
}

output "vnet_master_network_interface_ids" {
  value = "${module.vnet.master_network_interface_ids}"
}

output "vnet_master_private_ip_addresses" {
  value = "${module.vnet.master_private_ip_addresses}"
}

output "vnet_master_subnet" {
  value = "${module.vnet.master_subnet}"
}

output "vnet_vnet_id" {
  value = "${module.vnet.vnet_id}"
}

output "vnet_worker_cidr" {
  value = "${module.vnet.worker_cidr}"
}

output "vnet_worker_ip_addresses" {
  value = "${module.vnet.worker_private_ip_addresses}"
}

output "vnet_worker_network_interface_ids" {
  value = "${module.vnet.worker_network_interface_ids}"
}

output "vnet_worker_nsg_name" {
  value = "${module.vnet.worker_nsg_name}"
}

output "vnet_worker_private_ip_addresses" {
  value = "${module.vnet.worker_private_ip_addresses}"
}

output "vnet_worker_subnet" {
  value = "${module.vnet.worker_subnet}"
}

output "vnet_worker_subnet_name" {
  value = "${module.vnet.worker_subnet_name}"
}

output "workers_availability_set_name" {
  value = "${module.workers.availability_set_name}"
}
