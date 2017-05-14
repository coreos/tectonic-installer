// Install CoreOS to disk
resource "matchbox_group" "coreos_install" {
  count   = "${length(var.tectonic_metal_controller_names) + length(var.tectonic_metal_worker_names)}"
  name    = "${format("coreos-install-%s", element(concat(var.tectonic_metal_controller_names, var.tectonic_metal_worker_names), count.index))}"
  profile = "${matchbox_profile.coreos_install.name}"

  selector {
    mac = "${element(concat(var.tectonic_metal_controller_macs, var.tectonic_metal_worker_macs), count.index)}"
  }

  metadata {
    coreos_channel     = "${var.tectonic_cl_channel}"
    coreos_version     = "${var.tectonic_metal_cl_version}"
    ignition_endpoint  = "${var.tectonic_metal_matchbox_http_url}/ignition"
    baseurl            = "${var.tectonic_metal_matchbox_http_url}/assets/coreos"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"

    append_configs = ["${compact(list(
      module.custom-cacertificates.ignition_config_data_url,
      module.tectonic-registry-cache.ignition_config_data_url,
))}"]
  }
}

// DO NOT PLACE SECRETS IN USER-DATA

resource "matchbox_group" "controller" {
  count   = "${length(var.tectonic_metal_controller_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_controller_names, count.index))}"
  profile = "${matchbox_profile.tectonic_controller.name}"

  selector {
    mac = "${element(var.tectonic_metal_controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_controller_domains, count.index)}"
    k8s_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
    cni_bin_dir_flag   = "${var.tectonic_calico_network_policy ? "--cni-bin-dir=/var/lib/cni/bin" : "" }"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"
    exclude_tectonic   = "${var.tectonic_vanilla_k8s}"

    etcd_enabled = "${var.tectonic_experimental ? "false" : length(compact(var.tectonic_etcd_servers)) != 0 ? false : "true"}"

    etcd_initial_cluster = "${
      join(",", formatlist(
        var.tectonic_etcd_tls_enabled ? "%s=https://%s:2380" : "%s=http://%s:2380",
        var.tectonic_metal_controller_names,
        var.tectonic_metal_controller_domains
      ))
    }"

    etcd_name        = "${element(var.tectonic_metal_controller_names, count.index)}"
    etcd_scheme      = "${var.tectonic_etcd_tls_enabled ? "https" : "http"}"
    etcd_tls_enabled = "${var.tectonic_etcd_tls_enabled}"

    # extra data
    etcd_image_url    = "${replace(var.tectonic_container_images["etcd"],var.tectonic_image_re,"$1")}"
    etcd_image_tag    = "v${var.tectonic_versions["etcd"]}"
    kubelet_image_url = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
    kubelet_image_tag = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"

    rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
    rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

    # static IP
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_mac_address     = "${element(var.tectonic_metal_controller_macs, count.index)}"
    coreos_network_adapter = "${var.tectonic_metal_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_master_ip, count.index,"")}"
    coreos_network_gateway = "${var.tectonic_metal_master_gateway}"

    # custom CA Cert
    coreos_custom_cacertificate = "${replace(var.tectonic_metal_customcacertificate,"\n","\\n")}"

    # custom pause container image
    pod_infra_image = "${var.tectonic_container_images["pod_infra_image"]}"

    registry_cache_image                = "${var.tectonic_registry_cache_image}"
    registry_cache_repo                 = "${replace(var.tectonic_registry_cache_image, var.tectonic_image_re, "$1")}"
    registry_cache_tag                  = "${replace(var.tectonic_registry_cache_image, var.tectonic_image_re, "$2")}"
    registry_cache_rkt_protocol         = "${var.tectonic_registry_cache_rkt_protocol}"
    registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"

    append_configs = ["${compact(list(
      module.custom-cacertificates.ignition_config_data_url,
      module.tectonic-registry-cache.ignition_config_data_url,
))}"]
  }
}

resource "matchbox_group" "worker" {
  count   = "${length(var.tectonic_metal_worker_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_worker_names, count.index))}"
  profile = "${matchbox_profile.tectonic_worker.name}"

  selector {
    mac = "${element(var.tectonic_metal_worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_worker_domains, count.index)}"
    k8s_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
    cni_bin_dir_flag   = "${var.tectonic_calico_network_policy ? "--cni-bin-dir=/var/lib/cni/bin" : "" }"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"

    # extra data
    kubelet_image_url  = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
    kubelet_image_tag  = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"
    kube_version_image = "${var.tectonic_container_images["kube_version"]}"

    rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
    rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

    # static IP
    coreos_mac_address     = "${element(var.tectonic_metal_worker_macs, count.index)}"
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_network_adapter = "${var.tectonic_metal_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_worker_ip, count.index, "")}"
    coreos_network_gateway = "${var.tectonic_metal_worker_gateway}"

    # custom CA Cert
    coreos_custom_cacertificate = "${replace(var.tectonic_metal_customcacertificate,"\n","\\n")}"

    # custom pause container image
    pod_infra_image = "${var.tectonic_container_images["pod_infra_image"]}"

    registry_cache_image                = "${var.tectonic_registry_cache_image}"
    registry_cache_repo                 = "${replace(var.tectonic_registry_cache_image, var.tectonic_image_re, "$1")}"
    registry_cache_tag                  = "${replace(var.tectonic_registry_cache_image, var.tectonic_image_re, "$2")}"
    registry_cache_rkt_protocol         = "${var.tectonic_registry_cache_rkt_protocol}"
    registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"

    append_configs = ["${compact(list(
      module.custom-cacertificates.ignition_config_data_url,
      module.tectonic-registry-cache.ignition_config_data_url,
))}"]
  }
}
