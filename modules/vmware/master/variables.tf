variable "count" {
  type = "string"
  description = "Number of nodes to be created."
}

variable "base_domain" {
  type = "string"
}

variable kube_image_tag {
  type = "string"
  description = "The hyperkube image tag"
}

variable kube_image_url {
  type = "string"
  description = "The hyperkube image url"
}

variable kubeconfig_content {
  type = "string"
  description = "The content of the kubeconfig file."
}

variable etcd_fqdns {
  type = "list"
  description = "The fqdns of the etcd endpoints."
}

variable "core_public_keys" {
  type = "list"
}

variable "cluster_name" {
  type = "string"
  description = "Hostname will be prefixed with this string"
}

variable "tectonic_versions" {
  type = "map"
}

variable "tectonic_kube_dns_service_ip" {
  type = "string"
}

variable vmware_datacenter {
  type = "string"
  description = "vSphere Datacenter to create VMs in"
}

variable vmware_cluster  {
  type = "string"
  description = "vSphere Cluster to create VMs in"
}

variable vm_vcpu  {
  type = "string"
  description = "ETCD VMs vCPU count"
}

variable vm_memory  {
  type = "string"
  description = "ETCD VMs Memory size in MB"
}

variable vm_network_label {
  type = "string"
  description = "ETCD VMs PortGroup"
}

variable vm_disk_datastore  {
  type = "string"
  description   = "Datastore to create ETCD VM in "
}

variable vm_disk_template  {
  type = "string"
  description = "Disk template to use for cloning ETCD VM CoreOS Container Linux"
}

variable vm_disk_template_folder  {
  type = "string"
  description = "vSphere Folder CoreOS Container Linux is located in"
}

variable vmware_datastore {
  type = "string"
  description = "Datastore to enable Kubernetes - vSphere integration (vmdks are created here)"
}

variable vmware_folder {
  type = "string"
  description = "vSphere Folder to create Master VMs in"
}

variable vmware_username {
  type = "string"
  description = "vSphere username to enable Kubernetes - vSphere integration"
}

variable vmware_password {
  type = "string"
  description = "vSphere password to enable Kubernetes - vSphere integration"
}

variable vmware_server {
  type = "string"
  description = "vCenter Cerver FQDN/IP to enable Kubernetes - vSphere integration"
}

variable vmware_sslselfsigned {
  type = "string"
  description = "Set to True if vCenter SSL is self-signed for Kubernetes - vSphere integration"
}

variable dns_server {
  type = "string"
  description = "DNS Server of the nodes"
}

variable ip_address {
  type = "map"
  description = "IP Address of the node"
}

variable gateway {
  type = "string"
  description = "Gateway of the node"
}
