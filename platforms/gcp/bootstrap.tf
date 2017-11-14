module "bootstrapper" {
  source = "../../modules/bootstrap-ssh"

  _dependencies = [
    "${module.masters.instance_group}",
    "${module.network.ssh_master_forwarding_rule_self_link}",
    "${module.etcd.etcd_ip_addresses}",
    "${module.etcd_certs.id}",
    "${module.bootkube.id}",
    "${module.tectonic.id}",
    "${module.flannel_vxlan.id}",
    "${module.calico.id}",
    "${module.canal.id}",
  ]

  bootstrapping_host = "${module.network.ssh_master_ip}"

  # Giving enough times for the machines to be rebooted by k8s-node-bootstrap.service
  wait_time = "120"
}
