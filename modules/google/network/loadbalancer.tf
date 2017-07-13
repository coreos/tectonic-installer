resource "google_compute_health_check" "tectonic-master-backend-svc-healthcheck" {
  name = "tectonic-master-backend-svc-healthcheck"

  tcp_health_check {
    port = "443"
  }
}

resource "google_compute_region_backend_service" "tectonic-master-backend-svc" {
  name     = "tectonic-master-backend-svc"
  protocol = "TCP"
  region   = "${var.gcp_region}"

  backend {
    group = "${var.master_instance_group}"
  }

  health_checks = ["${google_compute_health_check.tectonic-master-backend-svc-healthcheck.self_link}"]
}

resource "google_compute_forwarding_rule" "tectonic-api-internal-fwd-rule" {
  load_balancing_scheme = "INTERNAL"
  name                  = "tectonic-api-internal-fwd-rule"
  region                = "${var.gcp_region}"
  subnetwork            = "${google_compute_subnetwork.tectonic-master-subnet.self_link}"
  backend_service       = "${google_compute_region_backend_service.tectonic-master-backend-svc.self_link}"
  ports                 = ["443"]
}

resource "google_compute_target_pool" "tectonic-master-targetpool" {
  name = "tectonic-master-targetpool"
}

resource "google_compute_target_pool" "tectonic-worker-targetpool" {
  name = "tectonic-worker-targetpool"
}

resource "google_compute_address" "tectonic-masters-ip" {
  name = "tectonic-masters-ip"
}

resource "google_compute_forwarding_rule" "tectonic-api-external-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-api-external-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-masters-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-master-targetpool.self_link}"
  port_range            = "443"
}

resource "google_dns_record_set" "api-external" {
  name         = "${var.cluster_name}.api.${var.base_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = "${var.managed_zone_name}"
  rrdatas      = ["${google_compute_address.tectonic-masters-ip.address}"]
}

resource "google_compute_address" "tectonic-ingress-ip" {
  name = "tectonic-ingress-ip"
}

resource "google_compute_forwarding_rule" "tectonic-ingress-external-http-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-ingress-external-http-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-ingress-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-worker-targetpool.self_link}"
  port_range            = "80"
}

resource "google_compute_forwarding_rule" "tectonic-ingress-external-https-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-ingress-external-https-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-ingress-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-worker-targetpool.self_link}"
  port_range            = "443"
}

resource "google_dns_record_set" "ingress-external" {
  name         = "${var.cluster_name}.${var.base_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = "${var.managed_zone_name}"
  rrdatas      = ["${google_compute_address.tectonic-ingress-ip.address}"]
}
