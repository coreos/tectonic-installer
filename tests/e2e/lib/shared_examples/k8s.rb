require 'smoke_test'

RSpec.shared_examples 'withCluster' do |tf_vars_path|
  before(:all) do
    AWS.check_prerequisites
    # TODO: Infer cluster name from tfvars file name
    @cluster = Cluster.new('aws', tf_vars_path)
    @cluster.start
  end

  after(:all) do
    @cluster.stop
  end

  it 'succeeds with the golang test suit' do
    SmokeTest.build
    SmokeTest.run(@cluster)
  end
end
