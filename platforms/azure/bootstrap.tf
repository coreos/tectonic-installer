locals {
  "bootstrapping_host" = "${var.tectonic_azure_private_cluster ? 
    module.vnet.master_private_ip_addresses[0] : 
    module.vnet.api_fqdn}"
}

module "bootstrapper" {
  source = "../../modules/bootstrap-ssh"

  # depends_on         = ["module.vnet", "module.dns", "module.etcd", "module.masters", "module.bootkube", "module.tectonic", "module.flannel-vxlan", "module.calico-network-policy"]
  vanilla_k8s        = "${var.tectonic_vanilla_k8s}"
  bootstrapping_host = "${local.bootstrapping_host}"
}
