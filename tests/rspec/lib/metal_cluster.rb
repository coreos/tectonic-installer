# frozen_string_literal: true

require 'cluster'
require 'json'
require 'jenkins'
require 'env_var'
require 'metal_support'

# AWSCluster represents a k8s cluster on AWS cloud provider
class MetalCluster < Cluster
  def initialize(tfvars_file)
    super(tfvars_file)
  end

  def env_variables
    root_dir = Dir.pwd
    variables = super
    variables['PLATFORM'] = 'metal'
    variables
  end

  def master_ip_address
    Dir.chdir(@build_path) do
      `echo 'var.tectonic_metal_controller_domains[0]' | terraform console ../../platforms/metal`.chomp
    end
  end

  def tectonic_console_url
    Dir.chdir(@build_path) do
      console_url = `echo var.tectonic_metal_ingress_domain | terraform console ../../platforms/metal`.chomp
      if console_url.empty?
        raise 'should get the console url to use in the UI tests.'
      end
      console_url
    end
  end
end
