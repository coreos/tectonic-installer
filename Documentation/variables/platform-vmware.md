# Terraform variables: platform-vmware
The Tectonic Installer variables used for: platform-vmware.

## Inputs
| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| tectonic_vmware_vm_template | The template of VM to be used for cloning | `` | yes |
| tectonic_vmware_vm_template_folder | vSphere folder in which VM template is located | `` | yes |
| tectonic_vmware_server | FQDN/IP of vCenter Server | `` | yes |
| tectonic_vmware_username | username for vCenter connectivity | `Administrator@vsphere.local` | no |
| tectonic_vmware_password | Password for vCenter connectivity | `` | yes |
| tectonic_vmware_sslselfsigned | set to true if vCenter SSL is self-signed | `` | yes |
| tectonic_vmware_folder | vSphere folder in which VMs will be deployed to | `` | yes |
| tectonic_vmware_datastore | vSphere datastore in which the VMs will be created | `` | yes |
| tectonic_vmware_datacenter | vDC in which VMs will be created | `` | yes |
| tectonic_vmware_cluster | vSphere cluster in which the VMs will be created | `` | yes |
| tectonic_vmware_etcd_vm_vcpu | Number of vCPUs assigned to etcd nodes | `1` | no |
| tectonic_vmware_etcd_vm_memory | Memory in MB assigned to etcd nodes | `4096` | no |
| tectonic_vmware_master_vm_vcpu | Number of vCPUs assigned to master nodes | `2` | no |
| tectonic_vmware_master_vm_memory | Memory in MB assigned to master nodes | `4096` | no |
| tectonic_vmware_worker_vm_vcpu | Number of vCPUs assigned to worker nodes | `2` | no |
| tectonic_vmware_worker_vm_memory | Memory in MB assigned to worker nodes | `4096` | no |
