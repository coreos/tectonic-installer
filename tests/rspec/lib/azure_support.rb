# frozen_string_literal: true

# Shared support code for Azure-based operations
#
module AzureSupport
  LOCATIONS = %w[eastus westus northcentralus southcentralus].freeze

  def self.random_location_unless_defined
    ENV['TF_VAR_tectonic_azure_location'] || LOCATIONS.sample
  end

  def self.set_ssh_key_path
    dir_home = `echo ${HOME}`.chomp
    ssh_pub_key_path = "#{dir_home}/.ssh/id_rsa.pub"
    ENV['TF_VAR_tectonic_azure_ssh_key'] = ssh_pub_key_path
    ssh_pub_key_path
  end
end
