# TODO: Can we remove or do we need to solve in a different way?
output "master_vm_ids" {
  value = ["${azurerm_virtual_machine_scale_set.tectonic_masters.*.id}"]
}
