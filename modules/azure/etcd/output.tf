output "node_names" {
  value = ["${slice(var.const_internal_node_names, 0, var.etcd_count)}"]
}
