// variables

variable "project_id" {
  type    = "string"
  default = ""
}

variable "facility" {
  type    = "string"
  default = "fra1"
}

variable "plan" {
  type    = "string"
  default = "baremetal_1e"
}

variable "hostname" {
  type    = "string"
  default = "tf"
}

variable "auth_token" {
  type    = "string"
  default = ""
}

variable "tectonic_pull_secret_path" {
  type    = "string"
  default = ""
}

variable "tectonic_license_path" {
  type    = "string"
  default = ""
}

// output

output "ip" {
  value = "${lookup(packet_device.machine.network[0], "address")}"
}

// resources/datasources/providers

resource "random_id" "hostname" {
  byte_length = 4
}

provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_device" "machine" {
  hostname         = "${var.hostname}-${var.facility}-${random_id.hostname.hex}"
  plan             = "${var.plan}"
  facility         = "${var.facility}"
  operating_system = "ubuntu_17_04"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
}

resource "null_resource" "tectonic" {
  depends_on = ["packet_device.machine"]

  connection {
    type    = "ssh"
    host    = "${lookup(packet_device.machine.network[0], "address")}"
    user    = "root"
    timeout = "60m"
  }

  provisioner "file" {
    source      = "terraform.tfvars.poc"
    destination = "$HOME/terraform.tfvars"
  }

  provisioner "file" {
    source      = "${var.tectonic_license_path}"
    destination = "$HOME/tectonic-license"
  }

  provisioner "file" {
    source      = "${var.tectonic_pull_secret_path}"
    destination = "$HOME/pull-secret"
  }

  provisioner "file" {
    destination = "$HOME/.bashrc"

    content = <<EOF
export TF_VAR_tectonic_pull_secret_path=/root/pull-secret
export TF_VAR_tectonic_license_path=/root/tectonic-license
export TF_VAR_tectonic_ssh_authorized_key=$(cat ~/.ssh/id_rsa.pub)

export KUBECONFIG=/root/go/src/github.com/coreos/tectonic-installer/build/poc/generated/auth/kubeconfig

export PATH=$PATH:/root/go/src/github.com/coreos/tectonic-installer/bin_test
which kubectl >/dev/null && source <(kubectl completion bash)
EOF
  }

  provisioner "file" {
    destination = "$HOME/install.sh"

    content = <<EOF
#/usr/bin/env bash

set -exou pipefail

cd $HOME

curl -OL# https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb
dpkg -i rkt_1.29.0-1_amd64.deb

echo "updating packages"
apt update -y
apt install --no-install-recommends -y \
  bzip2 \
  dnsutils \
  git \
  unzip \
  qemu-kvm \
  qemu-utils \
  libvirt-bin \
  mosh \
  virtinst \
  jq \
  easy-rsa

echo "installing Node.js"
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs
npm install -g yarn

echo "installing Go"
curl -OL# https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
tar xzf go1.9.2.linux-amd64.tar.gz
mv go /usr/local/go
ln -sf /usr/local/go/bin/go /usr/bin/go

echo "installing kubectl"
curl -OL# https://dl.k8s.io/v1.8.4/kubernetes-client-linux-amd64.tar.gz
tar xvzf kubernetes-client-linux-amd64.tar.gz
mv kubernetes/client/bin/kubectl /usr/local/bin/

echo "installing Terraform"
curl -OL# https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip
unzip terraform_0.10.8_linux_amd64.zip
mv terraform /usr/local/bin/

echo "installing CL config transpiler"
curl -OL# https://github.com/coreos/container-linux-config-transpiler/releases/download/v0.5.0/ct-v0.5.0-x86_64-unknown-linux-gnu
mv ct-v0.5.0-x86_64-unknown-linux-gnu ct
chmod +x ct
mv ct /usr/local/bin/

echo "generating ssh keys"
cd $HOME/.ssh
ssh-keygen -f id_rsa -t rsa -N ''
cd $HOME

mkdir -p $HOME/go/bin $HOME/go/pkg $HOME/go/src/github.com/coreos
git clone https://github.com/s-urbaniak/tectonic-installer $HOME/go/src/github.com/coreos/tectonic-installer
cd $HOME/go/src/github.com/coreos/tectonic-installer
git checkout poc

echo "installing rkt bridge CNI plugin"
mkdir -p /etc/rkt/net.d
cd platforms/poc/kvm
cp net.d/20-metal.conf /etc/rkt/net.d/

echo "starting DNS"
rkt fetch --insecure-options=all quay.io/coreos/dnsmasq
./poc start-dns
echo "nameserver 10.1.1.3" >/etc/resolv.conf

echo "installing CL image"
./poc download

echo "initializing .profile"
echo 'eval $(ssh-agent)' >>~/.profile
echo 'trap '"'"'kill $SSH_AGENT_PID'"'"' EXIT' >>~/.profile
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash $HOME/install.sh",
    ]
  }
}
