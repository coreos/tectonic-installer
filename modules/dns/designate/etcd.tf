resource "openstack_dns_recordset_v2" "etcd_srv_discover" {
  count   = "${var.designate_dns_enabled ? 1 : 0}"
  name    = "${var.etcd_tls_enabled ? "_etcd-server-ssl._tcp" : "_etcd-server._tcp"}"
  type    = "SRV"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  records = ["${formatlist("0 0 2380 %s", openstack_dns_recordset_v2.etc_a_nodes.*.fqdn)}"]
  ttl     = "300"
}

resource "openstack_dns_recordset_v2" "etcd_srv_client" {
  count   = "${var.designate_dns_enabled ? 1 : 0}"
  name    = "${var.etcd_tls_enabled ? "_etcd-client-ssl._tcp" : "_etcd-client._tcp"}"
  type    = "SRV"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  records = ["${formatlist("0 0 2379 %s", openstack_dns_recordset_v2.etc_a_nodes.*.fqdn)}"]
  ttl     = "60"
}

resource "openstack_dns_recordset_v2" "etc_a_nodes" {
  count   = "${var.designate_dns_enabled ? var.etcd_count : 0}"
  type    = "A"
  ttl     = "60"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  name    = "${var.cluster_name}-etcd-${count.index}"
  records = ["${var.etcd_ips[count.index]}"]
}
