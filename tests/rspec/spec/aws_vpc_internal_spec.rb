# frozen_string_literal: true

require 'shared_examples/k8s'
require 'aws_vpc'
require 'aws_region'
require 'jenkins'
require 'aws_iam'

RSpec.describe 'aws-vpc' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=aws"
  before(:all) do
    export_random_region_if_not_defined
    # AWSIAM.assume_role if Jenkins.environment?
    @vpc = AWSVPC.new('test-vpc')
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
