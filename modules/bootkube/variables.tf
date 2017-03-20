variable "container_images" {
    description = "Container images to use"
    type = "map"
}

variable "kube_apiserver_url" {
    description = "URL used to reach kube-apiserver"
    type        = "string"
}

variable "kube_apiserver_service_ip" {
    description = "Service IP used to reach kube-apiserver inside the cluster"
    type        = "string"
}

variable "kube_dns_service_ip" {
    description = "Service IP used to reach kube-dns"
    type        = "string"
}

variable "etcd_servers" {
    description = "List of etcd servers to connect with (scheme://ip:port)"
    type        = "list"
}

variable "cloud_provider" {
    description = "The provider for cloud services (empty string for no provider)"
    type        = "string"
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

variable "etcd_service_ip" {
    description = "Service IP used to reach etcd"
    type        = "string"
}

variable "experimental_self_hosted_etcd" {
    description = "Self hosted etcd mode. Includes starting the initial etcd member by bootkube"
    type        = "string"
    default     = "false"
}
