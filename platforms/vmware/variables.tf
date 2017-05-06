// # VMware Connectivity

variable "tectonic_vmware_vm_template" {
  type          = "string"
  description   = "Virtual Machine template of CoreOS Container Linux."
}

variable "tectonic_vmware_vm_template_folder" {
  type          = "string"
  description   = "Folder for VM template of CoreOS Container Linux."
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

// # Global

variable "tectonic_ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to use as an authorized key. Example: `\"ssh-rsa AAAB3N...\"`"
}

variable "tectonic_vmware_node_dns" {
  type = "string"
  description = "DNS Server in use by nodes"
}

variable "tectonic_vmware_controller_domain" {
  type        = "string"
  description = "The domain name which resolves to controller node(s)"
}

variable "tectonic_vmware_ingress_domain" {
  type        = "string"
  description = "The domain name which resolves to Tectonic Ingress (i.e. worker node(s))"
}

// # Node Settings

// ## ETCD

variable "tectonic_vmware_etcd_vcpu" {
  type          = "string"
  default       = "1"
  description   = "etcd node vCPU count"
}

variable "tectonic_vmware_etcd_memory" {
  type          = "string"
  default       = "4096"
  description   = "etcd node Memory Size in MB"
}

variable "tectonic_vmware_etcd_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}

variable "tectonic_vmware_etcd_ip" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_etcd_gateway" {
  type = "string"
  description = "gateway IP address for etcd Virtual Machine "
}

// ## Masters

variable "tectonic_vmware_master_vcpu" {
  type          = "string"
  default       = "1"
  description   = "master node vCPU count"
}

variable "tectonic_vmware_master_memory" {
  type          = "string"
  default       = "4096"
  description   = "master node Memory Size in MB"
}

variable "tectonic_vmware_master_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}

variable "tectonic_vmware_master_ip" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_master_gateway" {
  type = "string"
  description = "gateway IP address for master Virtual Machine "
}


// ## Workers

variable "tectonic_vmware_worker_vcpu" {
  type          = "string"
  default       = "1"
  description   = "worker node vCPU count"
}

variable "tectonic_vmware_worker_memory" {
  type          = "string"
  default       = "4096"
  description   = "worker node Memory Size in MB"
}

variable "tectonic_vmware_worker_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}

variable "tectonic_vmware_worker_ip" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_worker_gateway" {
  type = "string"
  description = "gateway IP address for worker Virtual Machine "
}

