# frozen_string_literal: true

require 'shared_examples/k8s'

RSpec.describe 'aws-standard' do
  include_examples('withBuildFolderSetupWithConfig', File.join(ENV['RSPEC_PATH'], '../smoke/aws/vars/aws-basic.yaml'))

  context 'with a cluster' do
    include_examples('withRunningClusterExistingBuildFolder', true)
  end
end
