# frozen_string_literal: true

require 'shared_examples/k8s'
require 'tls_certs'

DOMAIN = 'tectonic-ci.de'

RSpec.describe 'aws-custom-tls' do
  include_examples('withBuildFolderSetup', '../smoke/aws/vars/aws.tfvars.json')

  before(:all) do
    test_folder = File.expand_path('..', Dir.pwd)
    generate_tls("#{test_folder}/smoke/user_provided_tls/certs/", @name, DOMAIN, @tfvars_file.etcd_count)

    root_folder = File.expand_path('../..', Dir.pwd)
    custom_tls_tf = "#{test_folder}/smoke/user_provided_tls/tls.tf"
    dest_folder = "#{root_folder}/platforms/#{@tfvars_file.platform}"
    original_tls_tf = "#{dest_folder}/tls.tf"

    FileUtils.mv(original_tls_tf, "#{dest_folder}/tls.tf.original")
    FileUtils.cp(custom_tls_tf, dest_folder)
  end

  context 'with a cluster' do
    include_examples('withRunningClusterExistingBuildFolder')
  end
end
