package configgenerator

import (
	"strings"

	"github.com/coreos/tectonic-installer/installer/pkg/config"

	"github.com/coreos/tectonic-config/config/kube-addon"
	"github.com/coreos/tectonic-config/config/kube-core"
	"github.com/coreos/tectonic-config/config/tectonic-network"
	"github.com/coreos/tectonic-config/config/tectonic-utility"
	"github.com/ghodss/yaml"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type ConfigGenerator struct {
	config.Cluster
}

type ConfigurationObject struct {
	metav1.TypeMeta

	Metadata `json:"metadata,omitempty"`
	Data     map[string]string `json:"data,omitempty"`
}

type Data map[string]string

type Metadata struct {
	Name      string `json:"name,omitempty"`
	Namespace string `json:"namespace,omitempty"`
}

type UnmarshaledData map[string]interface{}

func New(cluster config.Cluster) ConfigGenerator {
	return ConfigGenerator{
		Cluster: cluster,
	}
}

func (c ConfigGenerator) KubeSystem() (string, error) {
	return configMap("kube-system", UnmarshaledData{
		"core-config":    c.coreConfig(),
		"network-config": c.networkConfig(),
	})
}

func (c ConfigGenerator) TectonicSystem() (string, error) {
	return configMap("tectonic-system", UnmarshaledData{
		"addon-config":   c.addonConfig(),
		"utility-config": c.utilityConfig(),
	})
}

func (c ConfigGenerator) addonConfig() *kubeaddon.OperatorConfig {
	addonConfig := kubeaddon.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: kubeaddon.APIVersion,
			Kind:       kubeaddon.Kind,
		},
	}

	return &addonConfig
}

func (c ConfigGenerator) coreConfig() *kubecore.OperatorConfig {
	coreConfig := kubecore.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: kubecore.APIVersion,
			Kind:       kubecore.Kind,
		},
	}

	coreConfig.InitialConfig.InitialMasterCount = c.Cluster.Masters.NodeCount
	coreConfig.NetworkConfig.ClusterCIDR = c.Cluster.Networking.NodeCIDR
	coreConfig.NetworkConfig.EtcdServers = strings.Join(c.Cluster.Etcd.ExternalServers, ",")
	coreConfig.NetworkConfig.ServiceCIDR = c.Cluster.Networking.ServiceCIDR

	return &coreConfig
}

func (c ConfigGenerator) networkConfig() *tectonicnetwork.OperatorConfig {
	networkConfig := tectonicnetwork.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: tectonicnetwork.APIVersion,
			Kind:       tectonicnetwork.Kind,
		},
	}

	networkConfig.PodCIDR = c.Cluster.Networking.PodCIDR
	networkConfig.CalicoConfig.MTU = c.Cluster.Networking.MTU

	return &networkConfig
}

func (c ConfigGenerator) utilityConfig() *tectonicutility.OperatorConfig {
	utilityConfig := tectonicutility.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: tectonicutility.APIVersion,
			Kind:       tectonicutility.Kind,
		},
	}

	return &utilityConfig
}

func configMap(namespace string, unmarshaledData UnmarshaledData) (string, error) {
	data := make(Data)

	for key, obj := range unmarshaledData {
		str, err := marshalYAML(obj)
		if err != nil {
			return "", err
		}
		data[key] = str
	}

	configurationObject := ConfigurationObject{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "ConfigMap",
		},
		Metadata: Metadata{
			Name:      "cluster-config-v1",
			Namespace: namespace,
		},
		Data: data,
	}

	str, err := marshalYAML(configurationObject)
	if err != nil {
		return "", err
	}
	return str, nil
}

func marshalYAML(obj interface{}) (string, error) {
	data, err := yaml.Marshal(&obj)
	if err != nil {
		return "", err
	}

	return string(data), nil
}
