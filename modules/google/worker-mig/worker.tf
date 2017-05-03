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

resource "google_compute_instance_template" "tectonic-worker-it" {
  name           = "tectonic-worker-it"
  machine_type   = "${var.machine_type}"
  can_ip_forward = false

  disk {
    source_image = "coreos-${var.cl_channel}"
    auto_delete  = true
    disk_type    = "${var.disk_type}"
    disk_size_gb = "${var.disk_size}"
  }

  network_interface {
    subnetwork = "${var.worker_subnetwork_name}"
    access_config = {
      // Ephemeral IP
    }
  }

  tags = ["tectonic-workers"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "tectonic-worker-mig" {
  count = "${var.instance_count}"
  name = "tectonic-worker-mig"
  zone = "${element(var.zone_list, count.index)}"
  instance_template  = "${google_compute_instance_template.tectonic-worker-it.self_link}"
  target_pools       = ["${var.worker_targetpool_self_link}"]
  base_instance_name = "tectonic-worker-mig"
}

resource "google_compute_autoscaler" "tectonic-worker-as" {
  name   = "tectonic-worker-as"
  zone = "${element(var.zone_list, count.index)}"
  target = "${google_compute_instance_group_manager.tectonic-worker-mig.self_link}"

  autoscaling_policy = {
    max_replicas    = "${var.max_workers}"
    min_replicas    = "${var.instance_count}"
    cooldown_period = 60

    cpu_utilization {
      target = 0.25
    }
  }
}

# vim: ts=2:sw=2:sts=2:et:ai
