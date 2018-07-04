package tls

import (
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"path/filepath"

	"github.com/coreos/tectonic-installer/installer/pkg/tls"
)

const (
	rootCACertPath = "generated/newTLS/root-ca.crt"
	rootCAKeyPath  = "generated/newTLS/root-ca.key"
)

// GenerateRootCerts creates the rootCAKey and rootCACert
func GenerateRootCerts(clusterDir string) (cert *x509.Certificate, key *rsa.PrivateKey, err error) {
	// generate key and certificate
	caKey, err := GeneratePrivateKey(clusterDir, rootCAKeyPath)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to generate private key: %v", err)
	}
	caCert, err := GenerateRootCA(clusterDir, caKey)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create a certificate: %v", err)
	}
	return caCert, caKey, nil
}

// GetCertFiles copies the given cert/key files into the generated folder and returns their contents
func GetCertFiles(clusterDir string, certPath string, keyPath string) (*x509.Certificate, *rsa.PrivateKey, error) {
	keyDst := filepath.Join(clusterDir, rootCAKeyPath)
	if err := copyFile(keyPath, keyDst); err != nil {
		return nil, nil, fmt.Errorf("failed to write file: %v", err)
	}

	certDst := filepath.Join(clusterDir, rootCACertPath)
	if err := copyFile(certPath, certDst); err != nil {
		return nil, nil, fmt.Errorf("failed to write file: %v", err)
	}
	// content validation occurs in pkg/config/validate.go
	// so no err should be returned at this stage
	certData, _ := ioutil.ReadFile(certPath)
	certPem, _ := pem.Decode([]byte(string(certData)))

	keyData, _ := ioutil.ReadFile(keyPath)
	keyPem, _ := pem.Decode([]byte(string(keyData)))

	key, err := x509.ParsePKCS1PrivateKey(keyPem.Bytes)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to process private key: %v", err)
	}
	cert, err := x509.ParseCertificates(certPem.Bytes)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to process certificate: %v", err)
	}

	return cert[0], key, nil
}

// GenerateCACerts creates the CA key, csr & cert
func GenerateCACerts(clusterDir string,
	caKey *rsa.PrivateKey,
	caCert *x509.Certificate,
	keyPath string,
	certPath string,
	commonName string,
	orgUnit string,
	keyUsages x509.KeyUsage) error {

	// create a private key
	key, err := GeneratePrivateKey(clusterDir, keyPath)
	if err != nil {
		return fmt.Errorf("failed to generate private key: %v", err)
	}

	// create a CSR
	csr, err := generateCSR(key, &pkix.Name{
		CommonName:         commonName,
		OrganizationalUnit: []string{orgUnit}})
	if err != nil {
		return fmt.Errorf("failed to create a certificate request: %v", err)
	}

	// create a CA cert
	cfg := &tls.CertCfg{KeyUsages: keyUsages}
	_, err = generateSignedCert(cfg, csr, key, caKey, caCert, clusterDir, certPath)
	if err != nil {
		return fmt.Errorf("failed to create a certificate: %v", err)
	}
	return nil
}

// GenerateRootCA creates and returns the root CA
func GenerateRootCA(path string, key *rsa.PrivateKey) (*x509.Certificate, error) {
	fileTargetPath := filepath.Join(path, rootCACertPath)
	cfg := &tls.CertCfg{
		Subject: pkix.Name{
			CommonName:         "root-ca",
			OrganizationalUnit: []string{"openshift"},
		},
		KeyUsages: x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
	}
	cert, err := tls.SelfSignedCACert(cfg, key)
	if err != nil {
		return nil, fmt.Errorf("error generating self signed certificate: %v", err)
	}
	if err := writeFile(fileTargetPath, certToPem(cert)); err != nil {
		return nil, err
	}
	return cert, nil
}

func generateCSR(key *rsa.PrivateKey, subject *pkix.Name) (*x509.CertificateRequest, error) {
	cfg := &tls.CSRCfg{Subject: *subject}
	csr, err := tls.CertificateRequest(cfg, key)
	if err != nil {
		return nil, fmt.Errorf("error creating certificate request: %v", err)
	}
	return csr, nil
}

func generateSignedCert(cfg *tls.CertCfg,
	csr *x509.CertificateRequest,
	key *rsa.PrivateKey,
	caKey *rsa.PrivateKey,
	caCert *x509.Certificate,
	clusterDir string,
	path string) (*x509.Certificate, error) {
	cert, err := tls.SignedCertificate(cfg, csr, key, caCert, caKey)
	if err != nil {
		return nil, fmt.Errorf("error signing certificate: %v", err)
	}
	fileTargetPath := filepath.Join(clusterDir, path)
	if err := writeFile(fileTargetPath, certToPem(cert)); err != nil {
		return nil, err
	}
	return cert, nil
}
