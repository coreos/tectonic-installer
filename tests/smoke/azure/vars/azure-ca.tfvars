tectonic_worker_count = "2"

tectonic_master_count = "2"

tectonic_etcd_count = "3"

tectonic_etcd_servers = [""]

tectonic_base_domain = "tectonic.dev.coreos.systems"

tectonic_cl_channel = "stable"

tectonic_admin_email = "example@coreos.com"

tectonic_admin_password_hash = "$2a$12$k9wa31uE/4uD9aVtT/vNtOZwxXyEJ/9DwXXEYB/eUpb9fvEPsH/kO" # PASSWORD

tectonic_ca_cert = "../../examples/fake-creds/ca.crt"

tectonic_ca_key = "../../examples/fake-creds/ca.key"

tectonic_azure_create_dns_zone = false
tectonic_azure_enable_ssh_external = "true"
tectonic_azure_etcd_storage_account_type = "Premium_LRS"
tectonic_azure_etcd_vm_size = "Standard_DS2_v2"
tectonic_azure_master_vm_size = "Standard_DS2_v2"
tectonic_azure_worker_vm_size = "Standard_DS2_v2"
tectonic_azure_master_storage_account_type = "Premium_LRS"
tectonic_azure_worker_storage_account_type = "Premium_LRS"
tectonic_azure_ssh_key = "/Users/alex/.ssh/id_rsa.pub"
tectonic_azure_vnet_cidr_block = "10.0.0.0/16"
// tectonic_base_domain = "westus2.cloudapp.azure.com"
