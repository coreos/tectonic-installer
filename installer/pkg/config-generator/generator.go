package configgenerator

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"

	"github.com/apparentlymart/go-cidr/cidr"
	"github.com/coreos/tectonic-config/config/kube-addon"
	"github.com/coreos/tectonic-config/config/kube-core"
	"github.com/coreos/tectonic-config/config/tectonic-network"
	tnco "github.com/coreos/tectonic-config/config/tectonic-node-controller"
	"github.com/coreos/tectonic-config/config/tectonic-utility"
	"github.com/ghodss/yaml"
	"golang.org/x/crypto/bcrypt"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

const (
	authConfigOIDCClientID        = "tectonic-kubectl"
	authConfigOIDCGroupsClaim     = "groups"
	authConfigOIDCUsernameClaim   = "email"
	networkConfigAdvertiseAddress = "0.0.0.0"
	identityConfigConsoleClientID = "tectonic-console"
	identityConfigKubectlClientID = "tectonic-kubectl"
	statsEmitterConfigStatsURL    = "https://stats-collector.tectonic.com"
	ingressConfigIngressKind      = "NodePort"
	certificatesStrategy          = "userProvidedCA"
	identityAPIService            = "tectonic-identity-api.tectonic-system.svc.cluster.local"

	generatedPath          = "generated"
	kcoConfigFileName      = "kco-config.yaml"
	tncoConfigFileName     = "tnco-config.yaml"
	kubeSystemPath         = "generated/manifests"
	kubeSystemFileName     = "cluster-config.yaml"
	tectonicSystemPath     = "generated/tectonic"
	tectonicSystemFileName = "cluster-config.yaml"
)

// ConfigGenerator defines the cluster config generation for a cluster.
type ConfigGenerator struct {
	config.Cluster
}

type configurationObject struct {
	metav1.TypeMeta

	Metadata metadata `json:"metadata,omitempty"`
	Data     data     `json:"data,omitempty"`
}

type data map[string]string

type metadata struct {
	Name      string `json:"name,omitempty"`
	Namespace string `json:"namespace,omitempty"`
}

type genericData map[string]interface{}

// New returns a ConfigGenerator for a cluster.
func New(cluster config.Cluster) ConfigGenerator {
	return ConfigGenerator{
		Cluster: cluster,
	}
}

// KubeSystem returns, if successful, a yaml string for the kube-system.
func (c ConfigGenerator) KubeSystem() (string, error) {
	tncoConfig, err := c.tncoConfig()
	if err != nil {
		return "", err
	}

	return configMap("kube-system", genericData{
		"kco-config":     c.coreConfig(),
		"network-config": c.networkConfig(),
		"tnco-config":    tncoConfig,
	})
}

// TectonicSystem returns, if successful, a yaml string for the tectonic-system.
func (c ConfigGenerator) TectonicSystem() (string, error) {
	utilityConfig, err := c.utilityConfig()
	if err != nil {
		return "", err
	}
	addonConfig, err := c.addonConfig()
	if err != nil {
		return "", err
	}
	return configMap("tectonic-system", genericData{
		"addon-config":   addonConfig,
		"utility-config": utilityConfig,
	})
}

// CoreConfig returns, if successful, a yaml string for the on-disk kco-config.
func (c ConfigGenerator) CoreConfig() (string, error) {
	return marshalYAML(c.coreConfig())
}

// TncoConfig returns, if successful, a yaml string for the on-disk tnco-config.
func (c ConfigGenerator) TncoConfig() (string, error) {
	tncoConfig, err := c.tncoConfig()
	if err != nil {
		return "", err
	}
	return marshalYAML(tncoConfig)
}

func (c ConfigGenerator) addonConfig() (*kubeaddon.OperatorConfig, error) {
	addonConfig := kubeaddon.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: kubeaddon.APIVersion,
			Kind:       kubeaddon.Kind,
		},
	}
	cidrhost, err := cidrhost(c.Cluster.Networking.ServiceCIDR, 10)
	if err != nil {
		return nil, err
	}
	addonConfig.DNSConfig.ClusterIP = cidrhost
	addonConfig.CloudProvider = c.Platform
	return &addonConfig, nil
}

func (c ConfigGenerator) coreConfig() *kubecore.OperatorConfig {
	coreConfig := kubecore.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: kubecore.APIVersion,
			Kind:       kubecore.Kind,
		},
	}
	coreConfig.ClusterConfig.APIServerURL = c.getAPIServerURL()
	coreConfig.AuthConfig.OIDCClientID = authConfigOIDCClientID
	coreConfig.AuthConfig.OIDCIssuerURL = c.getOicdIssuerURL()
	coreConfig.AuthConfig.OIDCGroupsClaim = authConfigOIDCGroupsClaim
	coreConfig.AuthConfig.OIDCUsernameClaim = authConfigOIDCUsernameClaim

	coreConfig.CloudProviderConfig.CloudConfigPath = ""
	coreConfig.CloudProviderConfig.CloudProviderProfile = strings.ToLower(c.Cluster.Platform)

	coreConfig.NetworkConfig.ClusterCIDR = c.Cluster.Networking.PodCIDR
	coreConfig.NetworkConfig.ServiceCIDR = c.Cluster.Networking.ServiceCIDR
	coreConfig.NetworkConfig.AdvertiseAddress = networkConfigAdvertiseAddress
	coreConfig.NetworkConfig.EtcdServers = c.getEtcdServersURLs()

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
	networkConfig.NetworkProfile = tectonicnetwork.NetworkType(c.Cluster.Networking.Type)

	return &networkConfig
}

func (c ConfigGenerator) tncoConfig() (*tnco.OperatorConfig, error) {
	tncoConfig := tnco.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: tnco.TNCOConfigAPIVersion,
			Kind:       tnco.TNCOConfigKind,
		},
	}

	tncoConfig.ControllerConfig = tnco.ControllerConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: tnco.TNCConfigAPIVersion,
			Kind:       tnco.TNCConfigKind,
		},
	}

	cidrhost, err := cidrhost(c.Cluster.Networking.ServiceCIDR, 10)
	if err != nil {
		return nil, err
	}

	tncoConfig.ControllerConfig.KubeconfigFetchCmd = "" // TODO(yifan): Get kubeconfigFetchCmd.
	tncoConfig.ControllerConfig.ClusterDNSIP = cidrhost
	tncoConfig.ControllerConfig.CloudProvider = strings.ToLower(c.Cluster.Platform)
	tncoConfig.ControllerConfig.CloudProviderConfig = "" // TODO(yifan): Get CloudProviderConfig.
	tncoConfig.ControllerConfig.ClusterName = c.Cluster.Name
	tncoConfig.ControllerConfig.BaseDomain = c.Cluster.BaseDomain
	tncoConfig.ControllerConfig.EtcdInitialCluster = c.etcdInitialCluster()
	tncoConfig.ControllerConfig.AdditionalConfigs = []string{} // TODO(yifan): Get additional configs.
	tncoConfig.ControllerConfig.NodePoolUpdateLimit = nil      // TODO(yifan): Get the node pool update limit.

	return &tncoConfig, nil
}

func (c ConfigGenerator) utilityConfig() (*tectonicutility.OperatorConfig, error) {
	utilityConfig := tectonicutility.OperatorConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: tectonicutility.APIVersion,
			Kind:       tectonicutility.Kind,
		},
	}

	var err error
	bytes, err := bcrypt.GenerateFromPassword([]byte(c.Admin.Password), 12)
	if err != nil {
		return nil, err
	}
	hashedAdminPassword := string(bytes)
	adminUserID, err := generateRandomID(16)
	if err != nil {
		return nil, err
	}
	consoleSecret, err := generateRandomID(16)
	if err != nil {
		return nil, err
	}
	KubectlSecret, err := generateRandomID(16)
	if err != nil {
		return nil, err
	}

	if err != nil {
		return nil, err
	}
	utilityConfig.IdentityConfig.AdminEmail = c.Admin.Email
	utilityConfig.IdentityConfig.AdminPasswordHash = hashedAdminPassword
	utilityConfig.IdentityConfig.AdminUserID = adminUserID
	utilityConfig.IdentityConfig.ConsoleClientID = identityConfigConsoleClientID
	utilityConfig.IdentityConfig.ConsoleSecret = consoleSecret
	utilityConfig.IdentityConfig.KubectlClientID = identityConfigKubectlClientID
	utilityConfig.IdentityConfig.KubectlSecret = KubectlSecret

	utilityConfig.IngressConfig.ConsoleBaseHost = c.getBaseAddress()
	utilityConfig.IngressConfig.IngressKind = ingressConfigIngressKind

	utilityConfig.StatsEmitterConfig.StatsURL = statsEmitterConfigStatsURL

	utilityConfig.TectonicConfigMapConfig.BaseAddress = c.getBaseAddress()
	utilityConfig.TectonicConfigMapConfig.CertificatesStrategy = certificatesStrategy
	utilityConfig.TectonicConfigMapConfig.ClusterID = c.Cluster.Internal.ClusterID
	utilityConfig.TectonicConfigMapConfig.ClusterName = c.Cluster.Name
	utilityConfig.TectonicConfigMapConfig.IdentityAPIService = identityAPIService
	utilityConfig.TectonicConfigMapConfig.InstallerPlatform = c.Cluster.Platform
	utilityConfig.TectonicConfigMapConfig.KubeAPIServerURL = c.getAPIServerURL()
	// TODO: Speficy what's a version in ut2 and set it here
	utilityConfig.TectonicConfigMapConfig.TectonicVersion = "ut2"

	return &utilityConfig, nil
}

func configMap(namespace string, unmarshaledData genericData) (string, error) {
	data := make(data)

	for key, obj := range unmarshaledData {
		str, err := marshalYAML(obj)
		if err != nil {
			return "", err
		}
		data[key] = str
	}

	configurationObject := configurationObject{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "ConfigMap",
		},
		Metadata: metadata{
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

// GenerateClusterConfigMaps returns, if successful, the cluster kubernetes configMaps
func (c ConfigGenerator) GenerateClusterConfigMaps(workspace string) error {
	clusterGeneratedPath := filepath.Join(workspace, generatedPath)
	if err := os.MkdirAll(clusterGeneratedPath, os.ModeDir|0755); err != nil {
		return fmt.Errorf("Failed to create cluster generated directory at %s", clusterGeneratedPath)
	}

	kcoConfig, err := c.CoreConfig()
	if err != nil {
		return err
	}

	kcoConfigFilePath := filepath.Join(clusterGeneratedPath, kcoConfigFileName)
	if err := writeFile(kcoConfigFilePath, kcoConfig); err != nil {
		return err
	}

	tncoConfig, err := c.TncoConfig()
	if err != nil {
		return err
	}

	tncoConfigFilePath := filepath.Join(clusterGeneratedPath, tncoConfigFileName)
	if err := writeFile(tncoConfigFilePath, tncoConfig); err != nil {
		return err
	}

	kubeSystem, err := c.KubeSystem()
	if err != nil {
		return err
	}

	kubePath := filepath.Join(workspace, kubeSystemPath)
	if err := os.MkdirAll(kubePath, os.ModeDir|0755); err != nil {
		return fmt.Errorf("Failed to create manifests directory at %s", kubePath)
	}

	kubeSystemConfigFilePath := filepath.Join(kubePath, kubeSystemFileName)
	if err := writeFile(kubeSystemConfigFilePath, kubeSystem); err != nil {
		return err
	}

	tectonicSystem, err := c.TectonicSystem()
	if err != nil {
		return err
	}

	tectonicPath := filepath.Join(workspace, tectonicSystemPath)
	if err := os.MkdirAll(tectonicPath, os.ModeDir|0755); err != nil {
		return fmt.Errorf("Failed to create tectonic directory at %s", tectonicPath)
	}

	tectonicSystemConfigFilePath := filepath.Join(tectonicPath, tectonicSystemFileName)
	return writeFile(tectonicSystemConfigFilePath, tectonicSystem)
}

func (c ConfigGenerator) getEtcdServersURLs() string {
	if len(c.Cluster.Etcd.External.Servers) > 0 {
		return strings.Join(c.Cluster.Etcd.External.Servers, ",")
	}
	etcdServers := make([]string, c.Cluster.NodeCount(c.Cluster.Etcd.NodePools))
	for i := range etcdServers {
		etcdServers[i] = fmt.Sprintf("https://%s-etcd-%v.%s:2379", c.Cluster.Name, i, c.Cluster.BaseDomain)
	}
	return strings.Join(etcdServers, ",")
}

func (c ConfigGenerator) getAPIServerURL() string {
	return fmt.Sprintf("https://%s-api.%s:443", c.Cluster.Name, c.Cluster.BaseDomain)
}

func (c ConfigGenerator) getBaseAddress() string {
	return fmt.Sprintf("%s.%s", c.Cluster.Name, c.Cluster.BaseDomain)
}

func (c ConfigGenerator) getOicdIssuerURL() string {
	return fmt.Sprintf("https://%s.%s/identity", c.Cluster.Name, c.Cluster.BaseDomain)
}

// generateRandomID reproduce tf random_id behaviour
// TODO: re-evaluate solution
func generateRandomID(byteLength int) (string, error) {
	bytes := make([]byte, byteLength)

	n, err := rand.Reader.Read(bytes)
	if n != byteLength {
		return "", errors.New("generated insufficient random bytes")
	}
	if err != nil {
		return "", err
	}

	b64Str := base64.RawURLEncoding.EncodeToString(bytes)

	return b64Str, nil
}

// GenerateClusterID reproduce tf cluster_id behaviour
// https://github.com/coreos/tectonic-installer/blob/master/modules/tectonic/assets.tf#L81
// TODO: re-evaluate solution
func GenerateClusterID(byteLength int) (string, error) {
	randomID, err := generateRandomID(byteLength)
	if err != nil {
		return "", err
	}
	bytes, err := base64.RawURLEncoding.DecodeString(randomID)
	hexStr := hex.EncodeToString(bytes)
	return fmt.Sprintf("%s-%s-%s-%s-%s",
		hexStr[0:8],
		hexStr[8:12],
		hexStr[12:16],
		hexStr[16:20],
		hexStr[20:32]), nil
}

// cidrhost takes an IP address range in CIDR notation
// and creates an IP address with the given host number.
// If given host number is negative, the count starts from the end of the range
// Reproduces tf behaviour.
// TODO: re-evaluate solution
func cidrhost(iprange string, hostNum int) (string, error) {
	_, network, err := net.ParseCIDR(iprange)
	if err != nil {
		return "", fmt.Errorf("invalid CIDR expression (%s): %s", iprange, err)
	}

	ip, err := cidr.Host(network, hostNum)
	if err != nil {
		return "", err
	}

	return ip.String(), nil
}

// etcdInitialCluster returns the string flag for `--initial-cluster`.
func (c ConfigGenerator) etcdInitialCluster() string {
	count := c.Cluster.NodeCount(c.Cluster.Etcd.NodePools)
	if count <= 0 {
		return `--initial-cluster=""`
	}

	var clusters []string
	for i := 0; i < count; i++ {
		endpoint := fmt.Sprintf("%s-etcd-%d.%s", c.Cluster.Name, i, c.Cluster.BaseDomain)
		clusters = append(clusters, fmt.Sprintf("%s=https://%s:2380", endpoint, endpoint))
	}

	return fmt.Sprintf("--initial-cluster=%s", strings.Join(clusters, ","))
}
