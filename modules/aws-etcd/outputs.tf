output "endpoints" {
  value = "${formatlist("%s:2379",aws_route53_record.etc_a_nodes.*.fqdn)}"
}
