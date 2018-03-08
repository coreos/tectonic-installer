package config

type Admin struct {
	Email    string `json:"-" yaml:"email,omitempty"`
	Password string `json:"-" yaml:"password,omitempty"`
}

type CA struct {
	Cert   string `json:"tectonic_ca_cert,omitempty" yaml:"cert,omitempty"`
	Key    string `json:"tectonic_ca_key,omitempty" yaml:"key,omitempty"`
	KeyAlg string `json:"tectonic_ca_key_alg,omitempty" yaml:"keyAlg,omitempty"`
}

type ContainerLinux struct {
	Channel string `json:"tectonic_container_linux_channel,omitempty" yaml:"channel,omitempty"`
	Version string `json:"tectonic_container_linux_version,omitempty" yaml:"version,omitempty"`
}

type DDNS struct {
	Key    `json:",inline" yaml:"key,omitempty"`
	Server string `json:"tectonic_ddns_server,omitempty" yaml:"secret,omitempty"`
}

type Key struct {
	Algorithm string `json:"tectonic_ddns_key_algorithm,omitempty" yaml:"algorithm,omitempty"`
	Name      string `json:"tectonic_ddns_key_name,omitempty" yaml:"name,omitempty"`
	Secret    string `json:"tectonic_ddns_key_secret,omitempty" yaml:"secret,omitempty"`
}

type Etcd struct {
	Count     int `json:"tectonic_etcd_count,omitempty" yaml:"-"`
	External  `json:",inline" yaml:"external,omitempty"`
	NodePools []string `json:"-" yaml:"nodePools"`
}

type External struct {
	CACertPath     string   `json:"tectonic_etcd_ca_cert_path,omitempty" yaml:"caCertPath,omitempty"`
	ClientCertPath string   `json:"tectonic_etcd_client_cert_path,omitempty" yaml:"clientCertPath,omitempty"`
	ClientKeyPath  string   `json:"tectonic_etcd_client_key_path,omitempty" yaml:"clientKeyPath,omitempty"`
	Servers        []string `json:"tectonic_etcd_servers,omitempty" yaml:"servers,omitempty"`
}

type ISCSI struct {
	Enabled bool `json:"tectonic_iscsi_enabled,omitempty" yaml:"enabled,omitempty"`
}

type NodePool struct {
	Count int    `json:"-" yaml:"count"`
	Name  string `json:"-" yaml:"name"`
}

type NodePools []NodePool

// Map returns a nodePools' map equivalent.
func (n NodePools) Map() map[string]int {
	m := make(map[string]int)
	for i := range n {
		m[n[i].Name] = n[i].Count
	}
	return m
}

type Master struct {
	Count     int      `json:"tectonic_master_count,omitempty" yaml:"-"`
	NodePools []string `json:"-" yaml:"nodePools"`
}

type Networking struct {
	Type        string `json:"tectonic_networking,omitempty" yaml:"type,omitempty"`
	MTU         string `json:"-" yaml:"mtu,omitempty"`
	ServiceCIDR string `json:"tectonic_service_cidr,omitempty" yaml:"serviceCIDR,omitempty"`
	PodCIDR     string `json:"tectonic_cluster_cidr,omitempty" yaml:"podCIDR,omitempty"`
}

type Proxy struct {
	HTTP  string `json:"tectonic_http_proxy_address,omitempty" yaml:"http,omitempty"`
	HTTPS string `json:"tectonic_https_proxy_address,omitempty" yaml:"https,omitempty"`
	No    string `json:"tectonic_no_proxy,omitempty" yaml:"no,omitempty"`
}

type Worker struct {
	Count     int      `json:"tectonic_worker_count,omitempty" yaml:"-"`
	NodePools []string `json:"-" yaml:"nodePools"`
}
