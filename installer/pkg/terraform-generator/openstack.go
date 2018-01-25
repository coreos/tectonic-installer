package terraformgenerator

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type OpenStack struct {
	DisableFloatingIP string `json:"tectonic_openstack_disable_floatingip,omitempty"`
	DNSNameservers    string `json:"tectonic_openstack_dns_nameservers,omitempty"`
	EtcdFlavorID      string `json:"tectonic_openstack_etcd_flavor_id,omitempty"`
	EtcdFlavorName    string `json:"tectonic_openstack_etcd_flavor_name,omitempty"`
	ExternalGatewayID string `json:"tectonic_openstack_external_gateway_id,omitempty"`
	FloatingIPPool    string `json:"tectonic_openstack_floatingip_pool,omitempty"`
	ImageID           string `json:"tectonic_openstack_image_id,omitempty"`
	ImageName         string `json:"tectonic_openstack_image_name,omitempty"`
	LBProvider        string `json:"tectonic_openstack_lb_provider,omitempty"`
	MasterFlavorID    string `json:"tectonic_openstack_master_flavor_id,omitempty"`
	MasterFlavorName  string `json:"tectonic_openstack_master_flavor_name,omitempty"`
	SubnetCIDR        string `json:"tectonic_openstack_subnet_cidr,omitempty"`
	WorkerFlavorID    string `json:"tectonic_openstack_worker_flavor_id,omitempty"`
	WorkerFlavorName  string `json:"tectonic_openstack_worker_flavor_name,omitempty"`
}

func NewOpenStack(cluster config.Cluster) OpenStack {
	return OpenStack{
	// DisableFloatingIP: "",
	// DNSNameservers:    "",
	// EtcdFlavorID:      "",
	// EtcdFlavorName:    "",
	// ExternalGatewayID: "",
	// FloatingipPool:    "",
	// ImageID:           "",
	// ImageName:         "",
	// LBProvider:        "",
	// MasterFlavorID:    "",
	// MasterFlavorName:  "",
	// SubnetCIDR:        "",
	// WorkerFlavorID:    "",
	// WorkerFlavorName:  "",
	}
}
