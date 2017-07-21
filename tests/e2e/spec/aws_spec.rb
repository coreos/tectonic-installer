require 'cluster'
require 'aws'
require 'shared_examples/k8s'

RSpec.describe 'aws' do
  before(:all) do
    AWS.check_prerequisites
    @cluster = Cluster.new('mxinden', '../smoke/aws/vars/aws.tfvars')
    @cluster.start
  end

  it_behaves_like('k8s-cluster')

  it 'starts up nodes' do
    expect(@cluster.amount_nodes).to be > 0
  end

  after(:all) do
    @cluster.stop
  end
end
