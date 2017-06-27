# Kubernetes Deployments and AppVersions TPR used in the payload
resource "template_dir" "upload_payload" {
  source_dir      = "../tectonic/resources/manifests/updater/"
  destination_dir = "./generated"

  vars {
    # Used variables for generating the payload,
    # just to make terraform happy.
    update_server = ""

    update_channel                 = ""
    update_app_id                  = ""
    node_agent_image               = ""
    prometheus_operator_image      = ""
    prometheus_config_reload_image = ""
    config_reload_image            = ""
    prometheus_image               = ""
    alertmanager_image             = ""

    # Actual variables we care about when generating the payload.
    container_linux_update_operator_image = "${lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images), "container_linux_update_operator")}"
    kube_version_operator_image           = "${lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images), "kube_version_operator")}"
    tectonic_channel_operator_image       = "${lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images), "tectonic_channel_operator")}"
    tectonic_prometheus_operator_image    = "${lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images), "tectonic_prometheus_operator")}"
    tectonic_etcd_operator_image          = "${lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images), "tectonic_etcd_operator")}"

    kubernetes_version             = "${var.tectonic_versions["kubernetes"]}"
    monitoring_version             = "${var.tectonic_versions["monitoring"]}"
    tectonic_version               = "${var.tectonic_versions["tectonic"]}"
    tectonic_etcd_operator_version = "${element(split(":", lookup(merge(var.tectonic_container_images, var.tectonic_user_container_images),"tectonic_etcd_operator")), 1)}"
  }
}
