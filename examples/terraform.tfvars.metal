
// The e-mail address used to:
// 1. login as the admin user to the Tectonic Console.
// 2. generate DNS zones for some providers.
// 
// Note: This field MUST be in all lower-case e-mail address format and set manually prior to creating the cluster.
tectonic_admin_email = ""

// The bcrypt hash of admin user password to login to the Tectonic Console.
// Use the bcrypt-hash tool (https://github.com/coreos/bcrypt-tool/releases/tag/v1.0.0) to generate it.
// 
// Note: This field MUST be set manually prior to creating the cluster.
tectonic_admin_password_hash = ""

// The base DNS domain of the cluster. It must NOT contain a trailing period. Some
// DNS providers will automatically add this if necessary.
// 
// Example: `openstack.dev.coreos.systems`.
// 
// Note: This field MUST be set manually prior to creating the cluster.
// This applies only to cloud platforms.
// 
// [Azure-specific NOTE]
// To use Azure-provided DNS, `tectonic_base_domain` should be set to `""`
// If using DNS records, ensure that `tectonic_base_domain` is set to a properly configured external DNS zone.
// Instructions for configuring delegated domains for Azure DNS can be found here: https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns
tectonic_base_domain = ""

// (optional) The content of the PEM-encoded CA certificate, used to generate Tectonic Console's server certificate.
// If left blank, a CA certificate will be automatically generated.
// tectonic_ca_cert = ""

// (optional) The content of the PEM-encoded CA key, used to generate Tectonic Console's server certificate.
// This field is mandatory if `tectonic_ca_cert` is set.
// tectonic_ca_key = ""

// (optional) The algorithm used to generate tectonic_ca_key.
// The default value is currently recommended.
// This field is mandatory if `tectonic_ca_cert` is set.
// tectonic_ca_key_alg = "RSA"

// [ALPHA] If set to true, calico network policy support will be deployed.
// WARNING: Enabling an alpha feature means that future updates may become unsupported.
// This should only be enabled on clusters that are meant to be short-lived to begin validating the alpha feature.
tectonic_calico_network_policy = false

// The Container Linux update channel.
// 
// Examples: `stable`, `beta`, `alpha`
tectonic_cl_channel = "stable"

// This declares the IP range to assign Kubernetes pod IPs in CIDR notation.
tectonic_cluster_cidr = "10.2.0.0/16"

// The name of the cluster.
// If used in a cloud-environment, this will be prepended to `tectonic_base_domain` resulting in the URL to the Tectonic console.
// 
// Note: This field MUST be set manually prior to creating the cluster.
// Warning: Special characters in the name like '.' may cause errors on OpenStack platforms due to resource name constraints.
tectonic_cluster_name = ""

// (optional) This only applies if you use the modules/dns/ddns module.
// 
// Specifies the RFC2136 Dynamic DNS server key algorithm.
// tectonic_ddns_key_algorithm = ""

// (optional) This only applies if you use the modules/dns/ddns module.
// 
// Specifies the RFC2136 Dynamic DNS server key name.
// tectonic_ddns_key_name = ""

// (optional) This only applies if you use the modules/dns/ddns module.
// 
// Specifies the RFC2136 Dynamic DNS server key secret.
// tectonic_ddns_key_secret = ""

// (optional) This only applies if you use the modules/dns/ddns module.
// 
// Specifies the RFC2136 Dynamic DNS server IP/host to register IP addresses to.
// tectonic_ddns_server = ""

// (optional) The path of the file containing the CA certificate for TLS communication with etcd.
// 
// Note: This works only when used in conjunction with an external etcd cluster.
// If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_client_cert_path`, and `tectonic_etcd_client_key_path` must also be set.
// tectonic_etcd_ca_cert_path = "/dev/null"

// (optional) The path of the file containing the client certificate for TLS communication with etcd.
// 
// Note: This works only when used in conjunction with an external etcd cluster.
// If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_ca_cert_path`, and `tectonic_etcd_client_key_path` must also be set.
// tectonic_etcd_client_cert_path = "/dev/null"

// (optional) The path of the file containing the client key for TLS communication with etcd.
// 
// Note: This works only when used in conjunction with an external etcd cluster.
// If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_ca_cert_path`, and `tectonic_etcd_client_cert_path` must also be set.
// tectonic_etcd_client_key_path = "/dev/null"

// The number of etcd nodes to be created.
// If set to zero, the count of etcd nodes will be determined automatically.
// 
// Note: This is not supported on bare metal.
tectonic_etcd_count = "0"

// (optional) List of external etcd v3 servers to connect with (hostnames/IPs only).
// Needs to be set if using an external etcd cluster.
// 
// Example: `["etcd1", "etcd2", "etcd3"]`
// tectonic_etcd_servers = ""

// (optional) If set to `true`, TLS secure communication for self-provisioned etcd. will be used.
// 
// Note: If `tectonic_experimental` is set to `true` this variable has no effect, because the experimental self-hosted etcd always uses TLS.
// tectonic_etcd_tls_enabled = true

// (optional) A set of paths that point to tls assets that have been pregenerated for the cluster. You can provide as many or as few certs as desired. The certificate files can include an intermediate certificate if necessary.<br>
// ca_crt_path:         The file location of a PEM-encoded CA certificate, used to generate the certificates that we will use to secure the tls enabled endpoints in tectonic.<br>
// ca_key_path:         The file location of a PEM-encoded CA key, used to sign all of the generated certificates. If left blank one will be generated.<br>
// ca_key_alg:          The algorithm used to generate the ca_key. The default value is recommended. This field is mandatory if `ca_key` is set.<br>
// ingress_crt_path:    The file location of the certificate that will be used to secure the ingress controller in front of the console and identity services.<br>
//                      This certificate should have the CN and Subject Alternate Name set. See RFC2818 for details<br>
// ingress_key_path:    The file location of the key that will be used to secure the ingress controller in front of the console and identity services.<br>
// apiserver_cert_path: The file location of the certificate that will be used to secure communication with the kube apiserver.<br>
//                      This certificate should have the following Subject Alternate Names set: "The common name used to address the api server", "kubernetes", "kubernetes.default",¬"kubernetes.default.svc",¬"kubernetes.default.svc.cluster.local" and a SAN IP of the ip in the service range. <br>
// apiserver_key_path:  The file location of the key that will be used to secure communication with the kube apiserver.<br>
// <br>
// tectonic_existing_certs = ""

// If set to true, experimental Tectonic assets are being deployed.
tectonic_experimental = false

// The path to the tectonic licence file.
// You can download the Tectonic license file from your Account overview page at [1].
// 
// [1] https://account.coreos.com/overview
// 
// Note: This field MUST be set manually prior to creating the cluster unless `tectonic_vanilla_k8s` is set to `true`.
tectonic_license_path = ""

// The number of master nodes to be created.
// This applies only to cloud platforms.
tectonic_master_count = "1"

// CoreOS kernel/initrd version to PXE boot.
// Must be present in Matchbox assets and correspond to `tectonic_cl_channel`.
// 
// Example: `1298.7.0`
tectonic_metal_cl_version = ""

// The domain name which resolves to controller node(s)
// 
// Example: `cluster.example.com`
tectonic_metal_controller_domain = ""

// Ordered list of controller domain names.
// 
// Example: `["node2.example.com", "node3.example.com"]`
tectonic_metal_controller_domains = ""

// Ordered list of controller MAC addresses for matching machines.
// 
// Example: `["52:54:00:a1:9c:ae"]`
tectonic_metal_controller_macs = ""

// Ordered list of controller names.
// 
// Example: `["node1"]`
tectonic_metal_controller_names = ""

// The domain name which resolves to Tectonic Ingress (i.e. worker node(s))
// 
// Example: `tectonic.example.com`
tectonic_metal_ingress_domain = ""

// The content of the Matchbox CA certificate to trust.
// 
// Example:
// ```
// <<EOD
// -----BEGIN CERTIFICATE-----
// MIIFDTCCAvWgAwIBAgIJAIuXq10k2OFlMA0GCSqGSIb3DQEBCwUAMBIxEDAOBgNV
// ...
// Od27a+1We/P5ey7WRlwCfuEcFV7nYS/qMykYdQ9fxHSPgTPlrGrSwKstaaIIqOkE
// kA==
// -----END CERTIFICATE-----
// EOD
// ```
tectonic_metal_matchbox_ca = ""

// The content of the Matchbox client TLS certificate.
// 
// Example:
// ```
// <<EOD
// -----BEGIN CERTIFICATE-----
// MIIEYDCCAkigAwIBAgICEAEwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UEAwwHZmFr
// ...
// jyXQv9IZPMTwOndF6AVLH7l1F0E=
// -----END CERTIFICATE-----
// EOD
// ```
tectonic_metal_matchbox_client_cert = ""

// The content of the Matchbox client TLS key.
// 
// Example:
// ```
// <<EOD
// -----BEGIN RSA PRIVATE KEY-----
// MIIEpQIBAAKCAQEAr8S7x/tAS6W+aRW3X833OvNfxXjUJAiRkUV85Raln7tqVcTG
// ...
// Pikk0rvNVB/vrPeVjAdGY9TJC/vpz3om92DRDmUifu8rCFxIHE0GrQ0=
// -----END RSA PRIVATE KEY-----
// EOD
// ```
tectonic_metal_matchbox_client_key = ""

// Matchbox HTTP read-only URL.
// 
// Example: `e.g. http://matchbox.example.com:8080`
tectonic_metal_matchbox_http_url = ""

// The Matchbox gRPC API endpoint.
// 
// Example: `matchbox.example.com:8081`
tectonic_metal_matchbox_rpc_endpoint = ""

// Ordered list of worker domain names.
// 
// Example: `["node2.example.com", "node3.example.com"]`
tectonic_metal_worker_domains = ""

// Ordered list of worker MAC addresses for matching machines.
// 
// Example: `["52:54:00:b2:2f:86", "52:54:00:c3:61:77"]`
tectonic_metal_worker_macs = ""

// Ordered list of worker names.
// 
// Example: `["node2", "node3"]`
tectonic_metal_worker_names = ""

// The path the pull secret file in JSON format.
// This is known to be a "Docker pull secret" as produced by the docker login [1] command.
// A sample JSON content is shown in [2].
// You can download the pull secret from your Account overview page at [3].
// 
// [1] https://docs.docker.com/engine/reference/commandline/login/
// 
// [2] https://coreos.com/os/docs/latest/registry-authentication.html#manual-registry-auth-setup
// 
// [3] https://account.coreos.com/overview
// 
// Note: This field MUST be set manually prior to creating the cluster unless `tectonic_vanilla_k8s` is set to `true`.
tectonic_pull_secret_path = ""

// This declares the IP range to assign Kubernetes service cluster IPs in CIDR notation. The maximum size of this IP range is /12
tectonic_service_cidr = "10.3.0.0/16"

// SSH public key to use as an authorized key.
// 
// Example: `ssh-rsa AAAB3N...`
tectonic_ssh_authorized_key = ""

// The Tectonic statistics collection URL to which to report.
tectonic_stats_url = "https://stats-collector.tectonic.com"

// If set to true, a vanilla Kubernetes cluster will be deployed, omitting any Tectonic assets.
tectonic_vanilla_k8s = false

// The number of worker nodes to be created.
// This applies only to cloud platforms.
tectonic_worker_count = "3"
