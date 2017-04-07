resource "vsphere_virtual_machine" "worker_node" {
  count     = "${var.count}"
  name      = "${var.cluster_name}-worker-${count.index}"
  datacenter      = "${var.vmware_datacenter}"
  cluster         = "${var.vmware_cluster}"
  vcpu            = "${var.vm_vcpu}"
  memory          = "${var.vm_memory}"
  folder          = "${var.vmware_folder}"
  
  network_interface {
    label         = "${var.vm_network_label}"
  }

  disk {
    datastore     = "${var.vm_disk_datastore}"  
    template      = "${var.vm_disk_template_folder}/${var.vm_disk_template}"
  }

  custom_configuration_parameters {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data = "${base64encode(ignition_config.worker.*.rendered[count.index])}"
    // UUID enablement is requiremd for Kubernetes vSphere Integration
    // see; https://kubernetes.io/docs/getting-started-guides/vsphere/
    disk.enableUUID = "1" 
    
  }
}