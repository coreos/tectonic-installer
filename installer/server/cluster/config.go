package cluster

// Config describes how a Tectonic cluster should be configured. It is possible to marshal Terraform configuration directly
// from Config.
type Config struct {
	// ClusterName
	ClusterName string `hcl:"tectonic_cluster_name"`

	// AdminEmail is the email used to login as the admin user to the Tectonic Console.
	AdminEmail string `hcl:"tectonic_admin_email"`

	BaseDomain string `hcl:"tectonic_base_domain"`

	ContainerLinuxChannel string `hcl:"tectonic_base_domain"`

	ClusterCIDR string `hcl:"tectonic_base_domain"`




}