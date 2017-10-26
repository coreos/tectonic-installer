# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'gcp-standard' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=gcp"
  include_examples('withRunningCluster', '../smoke/gcp/vars/gcp.tfvars.json')
end
