# frozen_string_literal: true

require 'json'

# GovcloudVPC represents an AWS virtual private cloud
class GovcloudVPC
  attr_reader :vpn_url
  attr_reader :ovpn_password
  attr_reader :name
  attr_reader :vpc_dns
  attr_reader :vpc_id
  attr_reader :private_zone_id
  attr_reader :master_subnet_ids
  attr_reader :worker_subnet_ids
  attr_reader :vpn_connection

  def initialize(name)
    @name = name
    @ovpn_password =
      `tr -cd '[:alnum:]' < /dev/urandom | head -c 32 ; echo`.chomp
  end

  def env_variables
    {
      'TF_VAR_vpc_aws_region' => 'us-gov-west-1',
      'TF_VAR_vpc_name' => @name,
      'TF_VAR_base_domain' => 'tectonic-ci.de',
      'TF_VAR_nginx_username' => 'openvpn',
      'TF_VAR_nginx_password' => @ovpn_password
    }
  end

  def export_tfvars
    vars = {
      'TF_VAR_tectonic_govcloud_external_vpc_id' => @vpc_id,
      'TF_VAR_tectonic_govcloud_external_master_subnet_ids' => @master_subnet_ids,
      'TF_VAR_tectonic_govcloud_external_worker_subnet_ids' => @worker_subnet_ids,
      'TF_VAR_tectonic_govcloud_dns_server_ip' => @vpc_dns,
      'TF_VAR_tectonic_govcloud_dns_server_api_url' => @dns_api_url,
      'TF_VAT_tectonic_govcloud_dns_server_api_key' => 'tectonicgov'
    }
    vars.each do |key, value|
      ENV[key] = value
    end
  end

  def create
    Dir.chdir('../../contrib/govcloud') do
      succeeded = system(env_variables, 'terraform init')
      raise 'could not init Terraform to create VPC' unless succeeded
      succeeded = system(env_variables, 'terraform apply -auto-approve')
      raise 'could not create vpc with Terraform' unless succeeded

      parse_terraform_output
      wait_for_vpn_access_server
      wait_for_dns_server

      @vpn_connection = GovcloudVPNConnection.new(@ovpn_password, @vpn_url)
      @vpn_connection.start
    end

    set_nameserver
    export_tfvars
  end

  def parse_terraform_output
    tf_out = JSON.parse(`terraform output -json`)
    @vpn_url = tf_out['ovpn_url']['value']
    @vpc_dns = tf_out['vpc_dns_ip']['value']
    @vpc_id = tf_out['vpc_id']['value']
    @dns_api_url = tf_out['dns_api_url']['value']
    parse_subnets(tf_out)
  end

  def parse_subnets(tf_out)
    subnets = tf_out['subnets']['value']
    @master_subnet_ids =
      "[\"#{subnets[0]}\", \"#{subnets[1]}\"]"
    @worker_subnet_ids =
      "[\"#{subnets[2]}\", \"#{subnets[3]}\"]"
  end

  def destroy
    @vpn_connection.stop
  rescue
    raise 'could not disconnect from vpn'
  ensure
    terraform_destroy
    recover_etc_resolv
  end

  def terraform_destroy
    Dir.chdir('../../contrib/govcloud') do
      3.times do
        return if system(env_variables, 'terraform destroy -force')
      end
    end

    raise 'could not destroy vpc with Terraform'
  end

  def wait_for_vpn_access_server
    90.times do
      succeeded = system("curl -k -L --silent -u 'openvpn:#{@ovpn_password}' #{@vpn_url} > /dev/null")
      return if succeeded
      sleep(5)
      puts 'waiting for vpn access server'
    end
    raise 'waiting for vpn access server timed out'
  end

  def wait_for_dns_server
    90.times do
      succeeded = system("curl -k -L --silent #{@vpn_url}:8081 > /dev/null")
      return if succeeded
      sleep(5)
      puts 'waiting for dns server'
    end
    raise 'waiting for dns server timed out'
  end

  def set_nameserver
    # Use AWS VPC DNS rather than host's.
    FileUtils.cp '/etc/resolv.conf', '/etc/resolv.conf.bak'
    IO.write('/etc/resolv.conf', "search us-gov-west-1.compute.internal\nnameserver #{@vpc_dns}\nnameserver 8.8.8.8\n")
    system('cat /etc/resolv.conf')
  end

  def recover_etc_resolv
    FileUtils.cp '/etc/resolv.conf.bak', '/etc/resolv.conf'
  end
end

# VPNConnection represents a VPN connection via the VPN server in an AWS VPC
class GovcloudVPNConnection
  attr_reader :vpn_url
  attr_reader :ovpn_password
  attr_reader :vpn_conf

  def initialize(ovpn_password, vpn_url)
    @ovpn_password = ovpn_password
    @vpn_url = vpn_url
  end

  def curl_vpn_config
    cmd = 'curl -k -L ' \
          "-u 'openvpn:#{@ovpn_password}' " \
          '--silent ' \
          '--fail ' \
          "#{@vpn_url}"

    @vpn_conf = `#{cmd}`.chomp
    IO.write('vpn.conf', @vpn_conf)
  end

  def start
    curl_vpn_config
    succeeded = system('openvpn --config vpn.conf --daemon')
    raise 'could not start vpn' unless succeeded

    wait_for_network
    puts 'Connection established.'
  end

  def stop
    system('pkill openvpn || true')
    wait_for_network
  end

  def wait_for_network
    90.times do
      succeeded = system('ping -c 1 8.8.8.8 > /dev/null')
      return if succeeded
    end
    raise 'waiting for network timed out'
  end
end
