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

resource "google_dns_record_set" "etcd_srv_discover" {
  name    = "_etcd-server._tcp.${var.base_domain}"
  type    = "SRV"
  managed_zone = "${var.managed_zone_name}"
  rrdatas = ["${format("0 0 2380 %s", google_dns_record_set.etc_a_node.name)}"]
  ttl     = "300"
}

resource "google_dns_record_set" "etcd_srv_client" {
  name    = "_etcd-client._tcp.${var.base_domain}"
  type    = "SRV"
  managed_zone = "${var.managed_zone_name}"
  rrdatas = ["${format("0 0 2379 %s", google_dns_record_set.etc_a_node.name)}"]
  ttl     = "60"
}

resource "google_dns_record_set" "etc_a_node" {
  type    = "A"
  ttl     = "60"
  managed_zone = "${var.managed_zone_name}"
  name    = "${var.cluster_name}-etcd.${var.base_domain}"
  rrdatas = ["${google_compute_instance.etcd-node.network_interface.0.address}"]
}

# vim: ts=2:sw=2:sts=2:et:ai
