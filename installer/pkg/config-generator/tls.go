package configgenerator

import (
	"crypto/rsa"
	"crypto/x509"
	"fmt"

	"github.com/coreos/tectonic-installer/installer/pkg/config-generator/tls"
)

const (
	kubeCACertPath           = "generated/newTLS/kube-ca.crt"
	kubeCAKeyPath            = "generated/newTLS/kube-ca.key"
	aggregatorCAKeyPath      = "generated/newTLS/aggregator-ca.key"
	aggregatorCACertPath     = "generated/newTLS/aggregator-ca.crt"
	serviceServiceCAKeyPath  = "generated/newTLS/service-serving-ca.key"
	serviceServiceCACertPath = "generated/newTLS/service-serving-ca.crt"
	etcdClientKeyPath        = "generated/newTLS/etcd-client-ca.key"
	etcdClientCertPath       = "generated/newTLS/etcd-client-ca.crt"
)

// GenerateTLSConfig fetches and validates the TLS cert files
// If no file paths were provided, the certs will be auto-generated
func (c *ConfigGenerator) GenerateTLSConfig(clusterDir string) error {
	var caKey *rsa.PrivateKey
	var caCert *x509.Certificate
	var errGlobal error

	if c.CA.RootCAKeyPath == "" && c.CA.RootCACertPath == "" {
		caCert, caKey, errGlobal = tls.GenerateRootCerts(clusterDir)
		if errGlobal != nil {
			return fmt.Errorf("failed to generate root CA certificate and key pair: %v", errGlobal)
		}
	} else {
		// copy key and certificates
		caCert, caKey, errGlobal = tls.GetCertFiles(clusterDir, c.CA.RootCACertPath, c.CA.RootCAKeyPath)
		if errGlobal != nil {
			return fmt.Errorf("failed to process CA certificate and key pair: %v", errGlobal)
		}
	}

	// generate kube CA
	if err := tls.GenerateCACerts(clusterDir, caKey, caCert, kubeCAKeyPath, kubeCACertPath, "kube-ca", "bootkube", x509.KeyUsageKeyEncipherment|x509.KeyUsageDigitalSignature|x509.KeyUsageCertSign); err != nil {
		return fmt.Errorf("failed to generate kube CAs: %v", err)
	}
	// generate aggregator CA
	if err := tls.GenerateCACerts(clusterDir, caKey, caCert, aggregatorCAKeyPath, aggregatorCACertPath, "aggregator", "bootkube", x509.KeyUsageKeyEncipherment|x509.KeyUsageDigitalSignature|x509.KeyUsageCertSign); err != nil {
		return fmt.Errorf("failed to generate aggregator CAs: %v", err)
	}
	// generate service-serving CA
	if err := tls.GenerateCACerts(clusterDir, caKey, caCert, serviceServiceCAKeyPath, serviceServiceCACertPath, "service-serving", "bootkube", x509.KeyUsageKeyEncipherment|x509.KeyUsageDigitalSignature|x509.KeyUsageCertSign); err != nil {
		return fmt.Errorf("failed to generate kube CAs: %v", err)
	}

	return nil
}
