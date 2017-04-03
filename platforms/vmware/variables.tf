// # vCenter Settings

variable "tectonic_vmware_vm_template" {
  type          = "string"
  description   = "Virtual Machine template of CoreOS Container Linux."
}

variable "tectonic_vmware_vm_template_folder" {
  type          = "string"
  description   = "Folder for VM template of CoreOS Container Linux."
  default       = "/vm"
}

variable "tectonic_vmware_server" {
  type          = "string"
  description   = "vCenter Server IP/FQDN"
} 

variable "tectonic_vmware_username" {
  type          = "string"
  default       = "Administrator@vsphere.local"
  description   = "Username to Use to connect to vCenter"
}

variable "tectonic_vmware_password" {
  type          = "string"
  description   = "Password to Use"
}

variable "tectonic_vmware_sslselfsigned" {
  type          = "string"
  description   = "Is the vCenter certificate Self-Signed?"
}

variable "tectonic_vmware_folder" {
  type          = "string"
  description   = "vSphere Folder to create and add the Tectonic objects to"
}

variable "tectonic_vmware_datastore" {
  type          = "string"
  description   = "Datastore to deploy the Cluster into"
}
 
variable "tectonic_vmware_network" {
  type          = "string"
  description   = "Portgroup to attach the cluster nodes into"
}

variable "tectonic_vmware_datacenter" {
  type          = "string"
  description   = "Virtual DataCenter to deploy VMs into"
}

variable "tectonic_vmware_cluster" {
  type          = "string"
  description   = "vCenter Cluster used to create VMs under"
}

// # Node Settings

variable "tectonic_vmware_etcd_vm_vcpu" {
  type          = "string"
  default       = "1"
  description   = "etcd node vCPU count"
}

variable "tectonic_vmware_etcd_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "etcd node Memory Size in MB"
}

variable "tectonic_vmware_master_vm_vcpu" {
  type          = "string"
  default       = "2"
  description   = "Master node vCPU count"
}

variable "tectonic_vmware_master_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "Master node Memory Size in MB"
}

variable "tectonic_vmware_worker_vm_vcpu" {
  type          = "string"
  default       = "2"
  description   = "Worker node vCPU count"
}

variable "tectonic_vmware_worker_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "Worker node Memory Size in MB"
}
