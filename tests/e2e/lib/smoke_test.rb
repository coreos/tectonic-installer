# SmokeTest contains helper functions to operate the smoke tests written in
# golang
module SmokeTest
  def self.build
    succeeded = system('make -C ../.. bin/smoke')
    raise 'Could not build smoke test binary' unless succeeded
  end

  def self.run(cluster)
    build unless compiled?

    succeeded = system(
      env_variables(cluster),
      './../../bin/smoke -test.v -test.parallel=1 --cluster'
    )
    raise 'SmokeTests failed' unless succeeded
  end

  def self.compiled?
    File.file?('../../bin/smoke')
  end
end

def env_variables(cluster)
  {
    'TEST_KUBECONFIG' => cluster.kubeconfig,
    'NODE_COUNT' => cluster.tfvars_file.node_count.to_s,
    'MANIFEST_PATHS' => cluster.manifest_path,
    'MANIFEST_EXPERIMENTAL' => bool_to_string(
      cluster.tfvars_file.experimental?
    ),
    'CALICO_NETWORK_POLICY' => bool_to_string(cluster.tfvars_file.calico?)
  }
end

def bool_to_string(bool)
  bool ? 'true' : 'false'
end
