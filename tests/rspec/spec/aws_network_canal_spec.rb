# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'aws-network-canal' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=aws"
  include_examples(
    'withRunningCluster',
    '../smoke/aws/vars/aws-net-canal.tfvars.json'
  )
end
