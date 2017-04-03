output "api_external_fqdn" {
  value = "${var.cluster_name}-k8s.${var.base_domain}"
}