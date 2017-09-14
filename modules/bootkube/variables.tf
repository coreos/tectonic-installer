variable "cluster_name" {
  type = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "versions" {
  description = "Container versions to use"
  type        = "map"
}

variable "kube_apiserver_url" {
  description = "URL used to reach kube-apiserver"
  type        = "string"
}

variable "apiserver_admission_control" {
  description = "Admission Controllers that are enabled for the kube apiserver."
  type        = "string"
  default     = "NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,PodSecurityPolicy"
}

variable "etcd_tls_enabled" {
  default = false
}

variable "etcd_cert_dns_names" {
  type = "list"
}

variable "etcd_endpoints" {
  description = "List of etcd endpoints to connect with (hostnames/IPs only)"
  type        = "list"
}

variable "etcd_ca_cert" {
  type = "string"
}

variable "etcd_client_cert" {
  type = "string"
}

variable "etcd_client_key" {
  type = "string"
}

variable "experimental_enabled" {
  description = "If set to true, provision experimental assets, like self-hosted etcd."
  default     = false
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

variable "service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs"
  type        = "string"
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}

variable "advertise_address" {
  description = "The IP address on which to advertise the apiserver to members of the cluster"
  type        = "string"
}

variable "ca_cert" {
  description = "PEM-encoded CA certificate (generated if blank)"
  type        = "string"
}

variable "ca_key_alg" {
  description = "Algorithm used to generate ca_key (required if ca_cert is specified)"
  type        = "string"
}

variable "ca_key" {
  description = "PEM-encoded CA key (required if ca_cert is specified)"
  type        = "string"
}

variable "anonymous_auth" {
  description = "Enables anonymous requests to the secure port of the API server"
  type        = "string"
}

variable "oidc_issuer_url" {
  description = "The URL of the OpenID issuer, only HTTPS scheme will be accepted"
  type        = "string"
}

variable "oidc_client_id" {
  description = "The client ID for the OpenID Connect client"
  type        = "string"
}

variable "oidc_username_claim" {
  description = "The OpenID claim to use as the user name"
  type        = "string"
}

variable "oidc_groups_claim" {
  description = "The OpenID claim to use for specifying user groups (string or array of strings)"
  type        = "string"
}

variable "master_count" {
  description = "The number of the master nodes"
  type        = "string"
}

variable "node_monitor_grace_period" {
  description = "Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status. N must be stricly > 1."
  type        = "string"
  default     = "40s"
}

variable "pod_eviction_timeout" {
  description = "The grace period for deleting pods on failed nodes. The eviction process will start after node_monitor_grace_period + pod_eviction_timeout."
  type        = "string"
  default     = "5m"
}

variable "cloud_config_path" {
  description = "The path to the secret file that contains the cloud config contents. Either be empty ('') or ('/etc/kubernetes/cloud/config')."
  type        = "string"
}
