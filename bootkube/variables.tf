# General configuration used by the module

variable "host" {
    description = "Host on which the assets will be generated and where bootkube will run"
    type        = "string"
}

variable "user" {
    description = "User that should be used to connect to the host"
    type        = "string"
    default     = "core"
}

variable "private_key" {
    description = "Private key that should be used to connect to the host"
    type        = "string"
    default     = ""
}

variable "assets_path" {
    description = "Absolute path in which the assets should be stored"
    type        = "string"
    default     = "/home/core/bootkube"
}

variable "bootkube_image" {
    description = "Bootkube image to run"
    type        = "string"
    default     = "quay.io/coreos/bootkube:v0.3.9"
}

# Configuration used for the assets generation

variable "hyperkube_image" {
    description = "Hyperkube image to use for Kubernetes components"
    type        = "string"
    default     = "quay.io/coreos/hyperkube:v1.5.3_coreos.0"
}

variable "pod_checkpointer_image" {
    description = "Checkpointer image to use"
    type        = "string"
    default     = "quay.io/coreos/pod-checkpointer:5b585a2d731173713fa6871c436f6c53fa17f754"
}

variable "kube_apiserver_url" {
    description = "URL used to reach kube-apiserver"
    type        = "string"
    default     = "https://127.0.0.1:443"
}

variable "kube_apiserver_service_ip" {
    description = "Service IP used to reach kube-apiserver"
    type        = "string"
    default     = "10.3.0.1"
}

variable "kube_dns_service_ip" {
    description = "Service IP used to reach kube-dns"
    type        = "string"
    default     = "10.3.0.10"
}

variable "etcd_servers" {
    description = "List of etcd servers to connect with (scheme://ip:port)"
    type        = "list"
    default     = ["http://127.0.0.1:2379"]
}

variable "cloud_provider" {
    description = "The provider for cloud services (empty string for no provider)"
    type        = "string"
    default     = ""
}

variable "service_cidr" {
    description = "A CIDR notation IP range from which to assign service cluster IPs"
    type        = "string"
    default     = "10.3.0.0/16"
}

variable "cluster_cidr" {
    description = "A CIDR notation IP range from which to assign pod IPs"
    type        = "string"
    default     = "10.2.0.0/16"
}

# Output

output "kubeconfig" {
    value = "${data.template_file.kubeconfig.rendered}"
}