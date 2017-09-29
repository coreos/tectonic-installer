# frozen_string_literal: true

require 'json'
require 'securerandom'
require 'net/http'
require 'uri'
require 'openssl'
require 'time'
require 'net/ssh'

PACKET_TEMPLATES = '../smoke/bare-metal/packet/*.tf'
MAX_RETRIES = 3
TIMEOUT_RETRIES = 30
TIMEOUT_RETRY_DELAY = 3

# Creates an instance in Packet.net to use as base machine to install Tectonic
#
class PacketSupport

  def initialize(tf_vars_file)
    raise 'Invalid tfvars file' if tf_vars_file.nil?
    @env_config = {
      'TF_VAR_project_id' => "e90b0633-d30d-4e95-8cfa-e8679b67cec5",
      'TF_VAR_auth_token' => "9w5h98nccggZKpKk4V4PeC89dsZ7Cbe5",
      'TF_VAR_hostname'   => "carlos-test",
      'tectonic_pull_secret_path' => ENV['TF_VAR_tectonic_pull_secret_path'],
      'tectonic_license_path' => ENV['TF_VAR_tectonic_license_path']
    }
    @build_dir = Dir.mktmpdir('tectonic-test-packet-')
    Dir.glob(PACKET_TEMPLATES) { |tf| FileUtils.cp(tf, @build_dir) }
    FileUtils.cp(tf_vars_file.path, "#{@build_dir}/terraform.tfvars")
  end

  def start
    create_resources
  end

  def create_resources
    Dir.chdir(@build_dir) do
      MAX_RETRIES.times do |count|
        raise 'Packet: init failed too many times' unless MAX_RETRIES > count
        break if system(@env_config, 'terraform init')
      end
      # MAX_RETRIES.times do |count|
      #   raise 'Packet: plan failed too many times' unless MAX_RETRIES > count
      #   break if system(@env_config, 'terraform plan')
      # end
      MAX_RETRIES.times do |count|
        raise 'Packet: apply failed too many times' unless MAX_RETRIES > count
        break if system(@env_config, 'terraform apply')
      end
    end
  end

  def stop
    if ENV.key?('TECTONIC_TESTS_DONT_CLEAN_UP')
      print 'Cleanup inhibiting flag set. Stopping here.'
      return
    end
    destroy_resources
    system("rm -rf #{@build_dir}")
  end

  def destroy_resources
    Dir.chdir(@build_dir) do
      MAX_RETRIES.times do |count|
        raise 'Packet: destroy failed too many times' unless MAX_RETRIES > count
        break if system(@env_config, 'terraform destroy -force')
      end
    end
  end
end