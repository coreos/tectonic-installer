package terraformgenerator

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type Azure struct {
	CloudEnvironment       string `json:"tectonic_azure_cloud_environment,omitempty"`
	EtcdStorageType        string `json:"tectonic_azure_etcd_storage_type,omitempty"`
	EtcdVMSize             string `json:"tectonic_azure_etcd_vm_size,omitempty"`
	ExternalDNSZoneID      string `json:"tectonic_azure_external_dns_zone_id,omitempty"`
	ExternalMasterSubnetID string `json:"tectonic_azure_external_master_subnet_id,omitempty"`
	ExternalNSGMasterID    string `json:"tectonic_azure_external_nsg_master_id,omitempty"`
	ExternalNSGWorkerID    string `json:"tectonic_azure_external_nsg_worker_id,omitempty"`
	ExternalResourceGroup  string `json:"tectonic_azure_external_resource_group,omitempty"`
	ExternalVNetID         string `json:"tectonic_azure_external_vnet_id,omitempty"`
	ExternalWorkerSubnetID string `json:"tectonic_azure_external_worker_subnet_id,omitempty"`
	ExtraTags              string `json:"tectonic_azure_extra_tags,omitempty"`
	MasterStorageType      string `json:"tectonic_azure_master_storage_type,omitempty"`
	MasterVMSize           string `json:"tectonic_azure_master_vm_size,omitempty"`
	PrivateCluster         string `json:"tectonic_azure_private_cluster,omitempty"`
	SSHKey                 string `json:"tectonic_azure_ssh_key,omitempty"`
	SSHNetworkExternal     string `json:"tectonic_azure_ssh_network_external,omitempty"`
	SSHNetworkInternal     string `json:"tectonic_azure_ssh_network_internal,omitempty"`
	VNetCIDRBlock          string `json:"tectonic_azure_vnet_cidr_block,omitempty"`
	WorkerStorageType      string `json:"tectonic_azure_worker_storage_type,omitempty"`
	WorkerVMSize           string `json:"tectonic_azure_worker_vm_size,omitempty"`
}

func NewAzure(cluster config.Cluster) Azure {
	return Azure{
	// CloudEnvironment:       "",
	// EtcdStorageType:        "",
	// EtcdVMSize:             "",
	// ExternalDNSZoneID:      "",
	// ExternalMasterSubnetID: "",
	// ExternalNSGMasterID:    "",
	// ExternalNSGWorkerID:    "",
	// ExternalResourceGroup:  "",
	// ExternalVNetID:         "",
	// ExternalWorkerSubnetID: "",
	// ExtraTags:              "",
	// MasterStorageType:      "",
	// MasterVMSize:           "",
	// PrivateCluster:         "",
	// SSHKey:                 "",
	// SSHNetworkExternal:     "",
	// SSHNetworkInternal:     "",
	// VNetCIDRBlock:          "",
	// WorkerStorageType:      "",
	// WorkerVMSize:           "",
	}
}
