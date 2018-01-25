package terraformgenerator

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type Metal struct {
	CalicoMTU           string `json:"tectonic_metal_calico_mtu,omitempty"`
	ControllerDomain    string `json:"tectonic_metal_controller_domain,omitempty"`
	ControllerDomains   string `json:"tectonic_metal_controller_domains,omitempty"`
	ControllerMACs      string `json:"tectonic_metal_controller_macs,omitempty"`
	ControllerNames     string `json:"tectonic_metal_controller_names,omitempty"`
	IngressDomain       string `json:"tectonic_metal_ingress_domain,omitempty"`
	MatchboxCA          string `json:"tectonic_metal_matchbox_ca,omitempty"`
	MatchboxClientCert  string `json:"tectonic_metal_matchbox_client_cert,omitempty"`
	MatchboxClientKey   string `json:"tectonic_metal_matchbox_client_key,omitempty"`
	MatchboxHTTPUrl     string `json:"tectonic_metal_matchbox_http_url,omitempty"`
	MatchboxRPCEndpoint string `json:"tectonic_metal_matchbox_rpc_endpoint,omitempty"`
	WorkerDomains       string `json:"tectonic_metal_worker_domains,omitempty"`
	WorkerMACs          string `json:"tectonic_metal_worker_macs,omitempty"`
	WorkerNames         string `json:"tectonic_metal_worker_names,omitempty"`
}

func NewMetal(cluster config.Cluster) Metal {
	return Metal{
	// CalicoMTU:           "",
	// ControllerDomain:    "",
	// ControllerDomains:   "",
	// ControllerMACs:      "",
	// ControllerNames:     "",
	// IngressDomain:       "",
	// MatchboxCA:          "",
	// MatchboxClientCert:  "",
	// MatchboxClientKey:   "",
	// MatchboxHTTPUrl:     "",
	// MatchboxRPCEndpoint: "",
	// WorkerDomains:       "",
	// WorkerMACs:          "",
	// WorkerNames:         "",
	}
}
