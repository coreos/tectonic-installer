output "ingress_external_fqdn" {
  value = "${var.base_domain != "" ? "${var.cluster_name}.${var.base_domain}" : ""}"
}

output "ingress_internal_fqdn" {
  value = "${var.base_domain != "" ? "${var.cluster_name}.${var.base_domain}" : ""}"
}

output "api_external_fqdn" {
  value = "${var.base_domain != "" ? "${var.cluster_name}-k8s.${var.base_domain}" : ""}"
}

output "api_internal_fqdn" {
  value = "${var.base_domain != "" ? "${var.cluster_name}-k8s.${var.base_domain}" : ""}"
}
