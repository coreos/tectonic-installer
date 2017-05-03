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

#resource "google_service_account" "tectonic-master-sa" {
#  account_id   = "tectonic-master-sa"
#  display_name = "tectonic-master-sa"
#}
#
#resource "google_project_iam_policy" "project-policy" {
#  project      = "${var.project_id}"
#  policy_data  = "${data.google_iam_policy.tectonic-master-policy.policy_data}"
#}
#
#data "google_iam_policy" "tectonic-master-policy" {
#  binding {
#    role = "roles/storage.objectReader"
#
#    members = [
#      "serviceAccount:${google_service_account.tectonic-master-sa.email}",
#    ]
#  }
#
#  binding {
#    role = "roles/compute.instanceAdmin"
#
#    members = [
#      "serviceAccount:${google_service_account.tectonic-master-sa.email}",
#    ]
#  }
#}

resource "google_compute_instance_template" "tectonic-master-it" {
  name           = "tectonic-master-it"
  machine_type   = "${var.machine_type}"
  can_ip_forward = false

  disk {
    source_image = "coreos-${var.cl_channel}"
    auto_delete  = true
    disk_type    = "${var.disk_type}"
    disk_size_gb = "${var.disk_size}"
  }

  network_interface {
    subnetwork = "${var.master_subnetwork_name}"
    access_config = {
      // Ephemeral IP
    }
  }

  tags = ["tectonic-masters"]

  service_account {
#    email  = "${google_service_account.tectonic-master-sa.email}"
#    scopes = ["compute", "storage-ro"]
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "tectonic-master-mig" {
  count = "${var.instance_count}"
  name = "tectonic-master-mig"
  zone = "${element(var.zone_list, count.index)}"
  instance_template  = "${google_compute_instance_template.tectonic-master-it.self_link}"
  target_pools       = ["${var.master_targetpool_self_link}"]
  base_instance_name = "tectonic-master-mig"
}

resource "google_compute_autoscaler" "tectonic-master-as" {
  name   = "tectonic-master-as"
  zone = "${element(var.zone_list, count.index)}"
  target = "${google_compute_instance_group_manager.tectonic-master-mig.self_link}"

  autoscaling_policy = {
    max_replicas    = "${var.max_masters}"
    min_replicas    = "${var.instance_count}"
    cooldown_period = 60

    cpu_utilization {
      target = 0.25
    }
  }
}

# vim: ts=2:sw=2:sts=2:et:ai
