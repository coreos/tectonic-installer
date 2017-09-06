# frozen_string_literal: true

require 'smoke_test'
require 'forensic'
require 'cluster_factory'
require 'operators'

RSpec.shared_examples 'withCluster' do |tf_vars_path|
  before(:all) do
    @cluster = ClusterFactory.from_tf_vars(TFVarsFile.new(tf_vars_path))
    @cluster.start
  end

  after(:each) do |example|
    Forensic.run(@cluster) if example.exception
  end

  after(:all) do
    @cluster.stop
  end

  it 'generates operator manifests' do
    expect { Operators.manifests_generated?(@cluster.manifest_path) }
      .to_not raise_error
  end

  it 'succeeds with the golang test suit' do
    expect { SmokeTest.run(@cluster) }.to_not raise_error
  end
end
