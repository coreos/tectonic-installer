# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'securerandom'
require 'net/http'
require 'uri'
require 'openssl'
require 'time'
require 'net/ssh'
require 'English'

PACKET_TEMPLATES = '../smoke/bare-metal/packet/*.tf'
MAX_RETRIES = 3
TIMEOUT_RETRIES = 30
TIMEOUT_RETRY_DELAY = 3

# Versions for Bare metal machine
MATCHBOX_VERSION="v0.6.1"
KUBECTL_VERSION="v1.6.4"
TERRAFORM_VERSION="0.10.7"

KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/#{KUBECTL_VERSION}/bin/linux/amd64/kubectl"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/#{TERRAFORM_VERSION}/terraform_#{TERRAFORM_VERSION}_linux_amd64.zip"

# Creates an instance in Packet.net to use as base machine to install Tectonic
#
module MetalSupport
  def self.install_base_software
    root = root_path()
    `sudo curl -L -o /usr/local/bin/kubectl #{KUBECTL_URL}`
    `sudo chmod +x /usr/local/bin/kubectl`
    `curl #{TERRAFORM_URL} | funzip > /tmp/terraform`
    `sudo mv /tmp/terraform /usr/local/bin/`
    `sudo chmod +x /usr/local/bin/terraform`
    `(cd #{root}/ && rm -rf matchbox && git clone https://github.com/coreos/matchbox)`
    `(cd #{root}/matchbox && git checkout #{MATCHBOX_VERSION})`
    puts "Finish Initial setup"
  end

  def self.setup_bare(varfile)

    # Copy the certificates to matchbox folder
    tectonic_folder = File.expand_path("../", Dir.pwd)
    root = root_path
    certs = Dir["#{tectonic_folder}/smoke/bare-metal/fake-creds/{ca.crt,server.crt,server.key}"]
    certs.each do |cert|
      filename_dest = cert.split("/")[-1]
      dest_folder = "#{root}/matchbox/examples/etc/matchbox/#{filename_dest}"
      FileUtils.cp(cert, dest_folder)
    end

    # Download CoreOS images
    system(self.env_variables, "#{root}/matchbox/scripts/get-coreos #{varfile.tectonic_container_linux_channel} #{varfile.tectonic_container_linux_version} ${ASSETS_DIR}")

    # Configuring ssh-agent
    `eval "$(ssh-agent -s)"`
    `sudo chmod 600 #{root}/matchbox/tests/smoke/fake_rsa`
    `ssh-add #{root}/matchbox/tests/smoke/fake_rsa`

    # Setting up the metal0 bridge
    `sudo mkdir -p /etc/rkt/net.d`
    `sudo cp #{root}/tests/rspec/utils/20-metal.conf /etc/rkt/net.d/`

    # Setting up DNS
    `grep -q "172.18.0.3" /etc/resolv.conf`
    if $CHILD_STATUS.exitstatus != 0
      `sudo cp /etc/resolv.conf /etc/resolv.conf.bak`
      `echo "nameserver 172.18.0.3" | cat - /etc/resolv.conf | sudo tee /etc/resolv.conf >/dev/null`
      puts `sudo cat /etc/resolv.conf`
    end
  end

  def self.start_matchbox
    root = root_path
    matchbox_dir = "#{root}/matchbox"
    Dir.chdir(matchbox_dir) do
      system(self.env_variables, 'sudo -E ./scripts/devnet create')
      wait_for_matchbox
      puts "Starting QEMU/KVM nodes"
      system(self.env_variables, 'sudo -E ./scripts/libvirt create')
    end
  end

  def self.destroy
    root = root_path
    matchbox_dir = "#{root}/matchbox"
    Dir.chdir(matchbox_dir) do
      system(self.env_variables, 'sudo -E ./scripts/devnet destroy')
      system(self.env_variables, 'sudo -E ./scripts/libvirt destroy')
    end
    # Restore resolv.conf
    `sudo cp /etc/resolv.conf.bak /etc/resolv.conf`
    `sudo cp /dev/null ${HOME}/.ssh/known_hosts`
    `for p in \`sudo rkt list | tail -n +2 | awk '{print $1}'\`; do sudo rkt stop --force $p; done`
    `sudo rkt gc --grace-period=0s`
    `for ns in \`ip netns l | grep -o -E '^[[:alnum:]]+'\`; do sudo ip netns del $ns; done; sudo ip l del metal0`
    `for veth in \`ip l show | grep -oE 'veth[^@]+'\`; do sudo ip l del $veth; done`
    `sudo rm -Rf /var/lib/cni/networks/*`
    `sudo rm -Rf /var/lib/rkt/*`
    `sudo rm -f /etc/rkt/net.d/20-metal.conf`
    `sudo systemctl reset-failed`
  end

  def self.wait_for_matchbox
    from = Time.now
    loop do
      out = `curl --silent --fail -k http://matchbox.example.com:8080 > /dev/null`
      if $CHILD_STATUS.exitstatus != 0
        puts "Waiting for matchbox..."
        elapsed = Time.now - from
        raise 'matchbox never returned with successful error code' if elapsed > 1200 # 20 mins timeout
        raise "dev-matchbox failed to load" if `sudo systemctl is-failed dev-matchbox`.chomp.include?("failed")
        raise "dev-dnsmasq failed to load" if `sudo systemctl is-failed dev-dnsmasq`.chomp.include?("failed")
        sleep 5
      else
        puts "Matchbox up and running..."
        break
      end
    end
  end

  def self.root_path
    File.expand_path("../../", Dir.pwd)
  end

  def self.env_variables
    {
      'VM_DISK' => "20",
      'VM_MEMORY' => "2048",
      'ASSETS_DIR' => "/tmp/matchbox/assets"
    }
  end

end
