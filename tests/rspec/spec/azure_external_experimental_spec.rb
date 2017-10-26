# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'azure-external-experimental' do
  puts "TestCase=#{self.description.to_s}"
  puts "platform=azure"
  include_examples('withRunningCluster', '../smoke/azure/vars/external-experimental.tfvars')
end
