# frozen_string_literal: true

require 'shared_examples/k8s'
require 'tls_certs'
require 'metal_support'

DOMAIN = 'example.com'

RSpec.describe 'metal-custom-tls' do
  include_examples('withBuildFolderSetup', '../smoke/bare-metal/vars/metal.tfvars.json')

  before(:all) do
    test_folder = File.expand_path('..', Dir.pwd)
    generate_tls("#{test_folder}/smoke/user_provided_tls/certs/", @name, DOMAIN, @tfvars_file.etcd_count)

    root_folder = File.expand_path('../..', Dir.pwd)
    custom_tls_tf = "#{test_folder}/smoke/user_provided_tls/tls.tf"
    dest_folder = "#{root_folder}/platforms/#{@tfvars_file.platform}"
    original_tls_tf = "#{dest_folder}/tls.tf"

    FileUtils.mv(original_tls_tf, "#{dest_folder}/tls.tf.original")
    FileUtils.cp(custom_tls_tf, dest_folder)

    MetalSupport.install_base_software
    MetalSupport.setup_bare(@tfvars_file)
    MetalSupport.start_matchbox(@tfvars_file)
  end

  after(:context) do |_context|
    MetalSupport.destroy
  end

  context 'with a cluster' do
    include_examples('withRunningClusterExistingBuildFolder')
  end
end
