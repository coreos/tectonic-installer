# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'gcp-ha' do
  include_examples('withRunningCluster', '../smoke/gcp/vars/gcp.kubenet.ha.tfvars.json')
end
