require 'smoke_test'

RSpec.shared_examples 'withCluster' do |tf_vars_path|
  before(:all) do
    AWS.check_prerequisites

    prefix = tf_vars_path.scan(%r{\/(.*).tfvars.json$}).first.first
    raise 'could not extract prefix from tfvars file name' if prefix == ''

    @cluster = Cluster.new(prefix, tf_vars_path)
    @cluster.start
  end

  after(:all) do
    @cluster.stop
  end

  it 'succeeds with the golang test suit' do
    SmokeTest.run(@cluster)
  end
end
