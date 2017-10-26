# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'aws-standard' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=aws"
  include_examples('withRunningCluster', '../smoke/aws/vars/aws.tfvars.json')
end
