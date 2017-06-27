output "node_names" {
  value = ["${slice(
    list("etcd-0", "etcd-1", "etcd-2", "etcd-3", "etcd-4", "etcd-5"),
    0, var.etcd_count
  )}"]
}
