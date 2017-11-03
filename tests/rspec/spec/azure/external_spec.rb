# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'azure-external' do
  include_examples('withRunningCluster',
                   '../smoke/azure/vars/external.tfvars')
end
