# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'aws-exp' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=aws"
  include_examples(
    'withPlannedCluster',
    '../smoke/aws/vars/aws-exp.tfvars.json'
  )
end
