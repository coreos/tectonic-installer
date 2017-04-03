module "etcd" {
  source = "../../modules/vmware/etcd"

  count                   = "1"
  cluster_name            = "${var.tectonic_cluster_name}"
  core_public_keys        = ["${module.secrets.core_public_key_openssh}"]

  vmware_datacenter       = "${var.tectonic_vmware_datacenter}"
  vmware_cluster          = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_etcd_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_etcd_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"
}

module "masters" {
  source = "../../modules/vmware/master"
  
  resolv_conf_content = <<EOF
search ${var.tectonic_base_domain}
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  etcd_fqdns                   = ["${var.tectonic_cluster_name}-etcd.${var.tectonic_base_domain}"]
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_master_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  vmware_username              = "${var.tectonic_vmware_username}"
  vmware_password              = "${var.tectonic_vmware_password}"
  vmware_server                = "${var.tectonic_vmware_server}"
  vmware_sslselfsigned         = "${var.tectonic_vmware_sslselfsigned}"
  vmware_datastore             = "${var.tectonic_vmware_datastore}"
  vmware_datacenter       = "${var.tectonic_vmware_datacenter}"
  vmware_cluster          = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_master_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_master_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

module "workers" {
  source = "../../modules/vmware/worker"
  
  resolv_conf_content = <<EOF
search ${var.tectonic_base_domain}
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  etcd_fqdns                   = ["${var.tectonic_cluster_name}-etcd.${var.tectonic_base_domain}"]
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_worker_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  vmware_username              = "${var.tectonic_vmware_username}"
  vmware_password              = "${var.tectonic_vmware_password}"
  vmware_server                = "${var.tectonic_vmware_server}"
  vmware_sslselfsigned         = "${var.tectonic_vmware_sslselfsigned}"
  vmware_datastore             = "${var.tectonic_vmware_datastore}"
  vmware_datacenter       = "${var.tectonic_vmware_datacenter}"
  vmware_cluster          = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_worker_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_worker_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

data "null_data_source" "local" {
  inputs = {
    kube_image_url = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kube_image_tag = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  }
}

module "dns" {
  source = "../../modules/vmware/dns-route53"

  cluster_name = "${var.tectonic_cluster_name}"
  base_domain  = "${var.tectonic_base_domain}"

  etcd_records = ["${module.etcd.ip_address}"]

  master_records = ["${module.masters.ip_address}"]
  master_count   = "${var.tectonic_master_count}"

  worker_records = ["${module.workers.ip_address}"]
  worker_count   = "${var.tectonic_worker_count}"

  tectonic_console_records = ["${module.workers.ip_address}"]
  tectonic_api_records     = ["${module.masters.ip_address}"]
}

module "secrets" {
  source       = "../../modules/vmware/secrets"
  cluster_name = "${var.tectonic_cluster_name}"
}
