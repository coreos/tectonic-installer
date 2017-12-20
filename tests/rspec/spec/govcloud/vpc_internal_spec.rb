# frozen_string_literal: true

require 'shared_examples/k8s'
require 'govcloud_vpc'
require 'aws_region'
require 'jenkins'
require 'aws_iam'

RSpec.describe 'govcloud-vpc' do
  include_examples('withBuildFolderSetup', '../smoke/govcloud/vars/govcloud-vpc-internal.tfvars.json')
  before(:all) do
    AWSIAM.assume_role if Jenkins.environment?
    @vpc = GovcloudVPC.new('test-vpc-govcloud')
    @vpc.create
  end

  context 'with a cluster' do
    include_examples('withRunningClusterExistingBuildFolder')
  end

  after(:all) do
    @vpc.destroy
  end
end
