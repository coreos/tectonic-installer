# SmokeTest contains helper functions to operate the smoke tests written in
# golang
module SmokeTest
  def self.build
    succeeded = system('make -C ../.. bin/smoke')
    raise 'Could not build smoke test binary' unless succeeded
  end

  def self.run(cluster)
    succeeded = system(
      { 'TEST_KUBECONFIG' => cluster.kubeconfig },
      './../../bin/smoke'
    )
    raise 'SmokeTests failed' unless succeeded
  end
end
