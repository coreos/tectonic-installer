require 'cluster'
require 'aws'
require 'shared_examples/k8s'

RSpec.describe 'aws-standard' do
  include_examples('withCluster', '../smoke/aws/vars/aws.tfvars')
end
