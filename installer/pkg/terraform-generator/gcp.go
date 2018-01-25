package terraformgenerator

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type GCP struct {
	ConfigVersion            string `json:"tectonic_gcp_config_version,omitempty"`
	EtcdDiskSize             string `json:"tectonic_gcp_etcd_disk_size,omitempty"`
	EtcdDisktype             string `json:"tectonic_gcp_etcd_disktype,omitempty"`
	EtcdGCEType              string `json:"tectonic_gcp_etcd_gce_type,omitempty"`
	ExtGoogleManagedZoneName string `json:"tectonic_gcp_ext_google_managedzone_name,omitempty"`
	MasterDiskSize           string `json:"tectonic_gcp_master_disk_size,omitempty"`
	MasterDisktype           string `json:"tectonic_gcp_master_disktype,omitempty"`
	MasterGCEType            string `json:"tectonic_gcp_master_gce_type,omitempty"`
	Region                   string `json:"tectonic_gcp_region,omitempty"`
	SSHKey                   string `json:"tectonic_gcp_ssh_key,omitempty"`
	WorkerDiskSize           string `json:"tectonic_gcp_worker_disk_size,omitempty"`
	WorkerDisktype           string `json:"tectonic_gcp_worker_disktype,omitempty"`
	WorkerGCEType            string `json:"tectonic_gcp_worker_gce_type,omitempty"`
}

func NewGCP(cluster config.Cluster) GCP {
	return GCP{
	// ConfigVersion:            "",
	// EtcdDiskSize:             "",
	// EtcdDisktype:             "",
	// EtcdGCEType:              "",
	// ExtGoogleManagedZoneName: "",
	// MasterDiskSize:           "",
	// MasterDisktype:           "",
	// MasterGCEType:            "",
	// Region:                   "",
	// SSHKey:                   "",
	// WorkerDiskSize:           "",
	// WorkerDisktype:           "",
	// WorkerGCEType:            "",
	}
}
