require 'kubectl_helpers'
require 'securerandom'
require 'jenkins'
require 'tfvars_file'

# Cluster represents a k8s cluster
class Cluster
  attr_reader :kubeconfig

  def initialize(prefix, tfvars_file_path)
    # Enable local testers to specify a static cluster name
    @name = ENV['CLUSTER']
    @name = generate_name(prefix) if @name == ''

    @tfvars_file = TFVarsFile.new(tfvars_file_path)

    @kubeconfig =
      `echo $(realpath ../../build)/#{@name}/generated/auth/kubeconfig`
      .delete("\n")
  end

  def start
    check_prerequisites
    localconfig
    prepare_assets
    plan
    # apply
    wait_til_ready
  end

  def stop
    # destroy
  end

  def amount_nodes
    out = parsed_kubectl(@kubeconfig, 'get nodes')
    out['items'].length
  end

  def check_prerequisites
    license_path = 'TF_VAR_tectonic_license_path'
    pull_secret_path = 'TF_VAR_tectonic_pull_secret_path'
    unless EnvVar.set?([license_path, pull_secret_path])
      raise 'TF_VAR_tectonic_pull_secret_path or TF_VAR_tectonic_license_path'\
            'are not defined as environment variables.'
    end

    cluster_domain = 'TF_VAR_base_domain'
    raise 'TF_VAR_base_domain is not defined' unless
      EnvVar.set?([cluster_domain])
  end

  private

  def env_variables
    { 'CLUSTER' => @name, 'TF_VAR_tectonic_cluster_name' => @name }
  end

  def prepare_assets
    puts Dir.pwd
    FileUtils.cp(
      @tfvars_file.path,
      Dir.pwd + "/../../build/#{@name}/terraform.tfvars"
    )
  end

  def localconfig
    puts env_variables
    succeeded = system(env_variables, 'make -C ../.. localconfig')
    raise 'Run localconfig failed' unless succeeded
  end

  def plan
    succeeded = system(env_variables, 'make -C ../.. plan')
    raise 'Planning cluster failed' unless succeeded
  end

  def apply
    succeeded = system(env_variables, 'make -C ../.. apply')
    raise 'Applying cluster failed' unless succeeded
  end

  def destroy
    retries = 0
    succeeded = false
    while retries < 3 && !succeeded
      succeeded = system(env_variables, 'make -C ../.. destroy')
      retries += 1
    end

    raise 'Destroying cluster failed' unless succeeded
  end

  def wait_til_ready
    retries = 0

    begin
      kubectl(@kubeconfig, 'cluster-info')
    rescue KubectlCmdFailed
      if retries < 100
        retries += 1
        sleep 10
        retry
      end
    end
  end

  MAX_NAME_LENGTH = 28
  RANDOM_HASH_LENGTH = 5

  def generate_name(prefix)
    name = prefix

    if Jenkins.environment?
      build_id = ENV['BUILD_ID']
      branch_name = ENV['BRANCH_NAME']
      name = "#{prefix}-#{branch_name}-#{build_id}"
    end

    name = name[0..(MAX_NAME_LENGTH - RANDOM_HASH_LENGTH)]
    name += SecureRandom.hex[0..RANDOM_HASH_LENGTH - 1]
    name
  end
end
