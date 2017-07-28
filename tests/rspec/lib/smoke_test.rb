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
    'SMOKE_KUBECONFIG' => cluster.kubeconfig,
    'SMOKE_NODE_COUNT' => cluster.tfvars_file.node_count.to_s,
    'SMOKE_MANIFEST_PATHS' => cluster.manifest_path,
    'SMOKE_MANIFEST_EXPERIMENTAL' => cluster.tfvars_file.experimental?.to_s,
    'SMOKE_CALICO_NETWORK_POLICY' => cluster.tfvars_file.calico?.to_s
  }
end
