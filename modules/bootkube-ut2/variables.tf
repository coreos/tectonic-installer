variable "advertise_address" {
  description = "The IP address on which to advertise the apiserver to members of the cluster"
  type        = "string"
}

variable "apiserver_cert_pem" {
  type        = "string"
  description = "The API server certificate in PEM format."
}

variable "apiserver_key_pem" {
  type        = "string"
  description = "The API server key in PEM format."
}

variable "apiserver_proxy_cert_pem" {
  type        = "string"
  description = "The API server proxy certificate in PEM format."
}

variable "apiserver_proxy_key_pem" {
  type        = "string"
  description = "The API server proxy key in PEM format."
}

variable "cloud_provider" {
  description = "The provider for cloud services (empty string for no provider)"
  type        = "string"
}

variable "cloud_provider_config" {
  description = "Content of cloud provider config"
  type        = "string"
  default     = ""
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "etcd_ca_cert_pem" {
  type        = "string"
  description = "The etcd CA certificate in PEM format."
}

variable "etcd_client_cert_pem" {
  type        = "string"
  description = "The etcd client certificate in PEM format."
}

variable "etcd_client_key_pem" {
  type        = "string"
  description = "The etcd client key in PEM format."
}

variable "etcd_endpoints" {
  description = "List of etcd endpoints to connect with (hostnames/IPs only)"
  type        = "list"
}

variable "etcd_peer_cert_pem" {
  type        = "string"
  description = "The etcd peer certificate in PEM format."
}

variable "etcd_peer_key_pem" {
  type        = "string"
  description = "The etcd peer key in PEM format."
}

variable "etcd_server_cert_pem" {
  type        = "string"
  description = "The etcd server certificate in PEM format."
}

variable "etcd_server_key_pem" {
  type        = "string"
  description = "The etcd server key in PEM format."
}

variable "kube_apiserver_url" {
  description = "URL used to reach kube-apiserver"
  type        = "string"
}

variable "root_ca_cert_pem" {
  type        = "string"
  description = "The Root CA in PEM format."
}

variable "aggregator_ca_cert_pem" {
  type        = "string"
  description = "The Aggregated API Server CA in PEM format."
}

variable "kube_ca_cert_pem" {
  type        = "string"
  description = "The Kubernetes CA in PEM format."
}

variable "kube_ca_key_pem" {
  type        = "string"
  description = "The Kubernetes CA key in PEM format."
}

variable "admin_cert_pem" {
  type        = "string"
  description = "The kubelet certificate in PEM format."
}

variable "admin_key_pem" {
  type        = "string"
  description = "The kubelet key in PEM format."
}

variable "master_count" {
  description = "The number of the master nodes"
  type        = "string"
}

variable "oidc_ca_cert" {
  type = "string"
}

variable "oidc_client_id" {
  description = "The client ID for the OpenID Connect client"
  type        = "string"
}

variable "oidc_groups_claim" {
  description = "The OpenID claim to use for specifying user groups (string or array of strings)"
  type        = "string"
}

variable "oidc_issuer_url" {
  description = "The URL of the OpenID issuer, only HTTPS scheme will be accepted"
  type        = "string"
}

variable "oidc_username_claim" {
  description = "The OpenID claim to use as the user name"
  type        = "string"
}

variable "cloud_config_path" {
  description = "The path to the secret file that contains the cloud config contents. Either be empty ('') or ('/etc/kubernetes/cloud/config')."
  type        = "string"
}

variable "service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs"
  type        = "string"
}

variable "versions" {
  description = "Container versions to use"
  type        = "map"
}

variable "pull_secret_path" {
  type        = "string"
  description = "Path on disk to your Tectonic pull secret. Obtain this from your Tectonic Account: https://account.coreos.com."
  default     = "/Users/coreos/Desktop/config.json"
}

variable "calico_mtu" {
  description = "sets the MTU size for workload interfaces and the IP-in-IP tunnel device"
  type        = "string"
}

variable "tectonic_networking" {
  description = "configures the network to be used in the cluster"
  type        = "string"
}

variable "http_proxy" {
  type        = "string"
  description = "HTTP proxy address."
}

variable "https_proxy" {
  type        = "string"
  description = "HTTPS proxy address."
}

variable "no_proxy" {
  type        = "list"
  description = "List of local endpoints that will not use HTTP proxy."
}

variable "iscsi_enabled" {
  type    = "string"
  default = "false"
}

variable "kubeconfig_fetch_cmd" {
  type        = "string"
  description = "(optional) The command that fetches `/etc/kubernetes/kubeconfig`."
  default     = ""
}

variable "bootstrap_upgrade_cl" {
  type        = "string"
  description = "(optional) Whether to trigger a ContainerLinux OS upgrade during the bootstrap process."
  default     = "true"
}

variable "torcx_store_url" {
  type        = "string"
  description = "(optional) URL template for torcx store. Leave empty to use the default CoreOS endpoint."
  default     = ""
}

variable "kubelet_node_taints" {
  type        = "string"
  description = "(optional) Taints that Kubelet will apply on the node"
  default     = ""
}

variable "kube_dns_service_ip" {
  type        = "string"
  description = "Service IP used to reach kube-dns"
}

variable "kubelet_debug_config" {
  type        = "string"
  default     = ""
  description = "internal debug flags for the kubelet (used in CI only)"
}

variable "kubelet_master_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the master node"
}

variable "kubelet_worker_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the worker node"
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type = "string"
}

variable "update_server_url" {
  description = "(optional) URL for the Container Linux update server. Leave empty to use the default CoreOS update server."
  type        = "string"
}
