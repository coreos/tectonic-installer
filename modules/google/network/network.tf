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

## Two public static IP addresses (masters and workers)
resource "google_compute_address" "tectonic-masters-ip" {
  name = "tectonic-masters-ip"
}
resource "google_compute_address" "tectonic-workers-ip" {
  name = "tectonic-workers-ip"
}

## A single GCP network
resource "google_compute_network" "tectonic-network" {
  name                    = "tectonic-network"
  auto_create_subnetworks = "false"
}

## Two subnetworks (masters, workers)
resource "google_compute_subnetwork" "tectonic-master-subnet" {
  name          = "tectonic-master-subnet"
  ip_cidr_range = "${var.master_ip_cidr_range}"
  network       = "${google_compute_network.tectonic-network.self_link}"
  region        = "${var.gcp_region}"
}
resource "google_compute_subnetwork" "tectonic-worker-subnet" {
  name          = "tectonic-worker-subnet"
  ip_cidr_range = "${var.worker_ip_cidr_range}"
  network       = "${google_compute_network.tectonic-network.self_link}"
  region        = "${var.gcp_region}"
}

## Need two targetpools (masters, workers)
resource "google_compute_target_pool" "tectonic-master-targetpool" {
  name = "tectonic-master-targetpool"
}
resource "google_compute_target_pool" "tectonic-worker-targetpool" {
  name = "tectonic-worker-targetpool"
}

## Two forwarding rules
resource "google_compute_forwarding_rule" "tectonic-master-fwd-rule" {
  name        = "tectonic-master-fwd-rule"
  ip_address  = "${google_compute_address.tectonic-masters-ip.self_link}"
  region      = "${var.gcp_region}"
  target      = "${google_compute_target_pool.tectonic-master-targetpool.self_link}"
  description = "Regional TCP forwarding rule for masters."
}
resource "google_compute_forwarding_rule" "tectonic-worker-fwd-rule" {
  name        = "tectonic-worker-fwd-rule"
  ip_address  = "${google_compute_address.tectonic-workers-ip.self_link}"
  region      = "${var.gcp_region}"
  target      = "${google_compute_target_pool.tectonic-worker-targetpool.self_link}"
  description = "Regional TCP forwarding rule for workers."
}

## Firewall rules
## see https://github.com/coreos/tectonic-installer/blob/master/Documentation/generic-platform.md
resource "google_compute_firewall" "tectonic-allow-ssh" {
  name    = "tectonic-allow-ssh"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "tectonic-master-ingress" {
  name    = "tectonic-master-ingress"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["32000-32002"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "tectonic-prometheus" {
  name    = "tectonic-prometheus"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }
  source_tags = ["tectonic-workers", "tectonic-masters"]
}
resource "google_compute_firewall" "tectonic-master-kubelet-ro" {
  name    = "tectonic-master-kubelet-ro"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["10255"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "tectonic-worker-openmasters" {
  name    = "tectonic-worker-openmasters"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    # includes tcp:10250 for k8s features
    # includes tcp:9100 for prometheus (also covered in another rule)
    # includes tcp:4194 for heapster to cadvisor
  }
  source_tags = ["tectonic-masters"]
}
resource "google_compute_firewall" "tectonic-worker-nodeports" {
  name    = "tectonic-worker-nodeports"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "tectonic-worker-etcd" {
  name    = "tectonic-worker-etcd"
  network = "${google_compute_network.tectonic-network.name}"
  allow {
    protocol = "tcp"
    ports    = ["2379-2380"] # self-hosted etcd and etcd-operator
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_dns_record_set" "cluster-api" {
  name         = "${var.cluster_name}.api.${var.base_domain}"
  type         = "A"
  ttl          = 300
  managed_zone = "${var.managed_zone_name}"
  rrdatas = ["${google_compute_address.tectonic-masters-ip.address}"]
}

resource "google_dns_record_set" "cluster-apps" {
  name         = "${var.cluster_name}.apps.${var.base_domain}"
  type         = "A"
  ttl          = 300
  managed_zone = "${var.managed_zone_name}"
  rrdatas = ["${google_compute_address.tectonic-workers-ip.address}"]
}

# vim: ts=2:sw=2:sts=2:et:ai
