require 'smoke_test'

RSpec.shared_examples 'k8s-cluster' do
  it 'succeeds with the golang test suit' do
    SmokeTest.build
    SmokeTest.run(@cluster)
  end
end
