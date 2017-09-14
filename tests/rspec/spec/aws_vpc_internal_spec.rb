# frozen_string_literal: true

require 'shared_examples/k8s'
require 'aws_vpc'
require 'aws_region'
require 'jenkins'
require 'aws_iam'

RSpec.describe 'aws-vpc' do
  before(:all) do
    export_random_region_if_not_defined
    AWSIAM.assume_role if Jenkins.environment?
    vpc_name = 'test-local-vpc'
    vpc_name = "#{ENV['BRANCH_NAME']}-#{ENV['BUILD_ID']}-vpc" if Jenkins.environment?
    @vpc = AWSVPC.new(vpc_name)
    @vpc.create
  end

  context 'with a cluster' do
    include_examples(
      'withRunningCluster',
      '../smoke/aws/vars/aws-vpc-internal.tfvars.json'
    )
  end

  after(:all) do
    @vpc.destroy
  end
end
