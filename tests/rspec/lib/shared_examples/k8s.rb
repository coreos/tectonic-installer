# frozen_string_literal: true

require 'shared_examples/build_folder_setup'
require 'shared_examples/tls_setup'
require 'smoke_test'
require 'cluster_factory'
require 'container_linux'
require 'operators'
require 'name_generator'
require 'password_generator'
require 'test_container'
require 'with_retries'
require 'jenkins'

RSpec.shared_examples 'withRunningCluster' do |tf_vars_path, vpn_tunnel = false|
  include_examples('withBuildFolderSetup', tf_vars_path)
  include_examples('withRunningClusterExistingBuildFolder', vpn_tunnel)
end

RSpec.shared_examples 'withRunningClusterWithCustomTLS' do |tf_vars_path, domain, vpn_tunnel = false|
  include_examples('withBuildFolderSetup', tf_vars_path)
  include_examples('withTLSSetup', domain)
  include_examples('withRunningClusterExistingBuildFolder', vpn_tunnel)
end

RSpec.shared_examples 'withRunningClusterExistingBuildFolder' do |vpn_tunnel = false, exist_plat = nil, exist_cfg_file = nil|
  before(:all) do
    # See https://stackoverflow.com/a/45936219/4011134
    @exceptions = []

    @cluster = if exist_plat.nil? && exist_cfg_file.nil? && @config_file.nil?
                 ClusterFactory.from_tf_vars(@tfvars_file)
               elsif @config_file.platform.include?('aws') && @tfvars_file.nil?
                 ClusterFactory.from_config_file(@config_file)
               else
                 ClusterFactory.hard_coded_aws(exist_plat, exist_cfg_file)
               end

    @cluster.init
    @cluster.start if exist_plat.nil? && exist_cfg_file.nil?
  end

  # after(:all) hooks that are defined first are executed last
  # Make sure to run `@cluster.stop` after `@cluster.forensic`
  after(:all) do
    begin
      @cluster.stop if exist_plat.nil? && exist_cfg_file.nil?
    rescue => e
      puts "Destroy failed, however we will not fail the test. Error: #{e}"
    end
  end

  # See https://stackoverflow.com/a/45936219/4011134
  after(:each) do |example|
    @exceptions << example.exception
  end

  after(:all) do
    @cluster.forensic if @exceptions.any?
  end

  it 'generates operator manifests' do
    expect { Operators.manifests_generated?(@cluster.manifest_path) }
      .to_not raise_error
  end

  it 'verifies api checkpoint manifests' do
    @cluster.master_ip_addresses.each do |ip|
      cmd = "sudo sh -c 'cat /etc/kubernetes/inactive-manifests/kube-system-kube-apiserver-*.json'"

      Retriable.with_retries(limit: 20, sleep: 3) do
        stdout, stderr, exit_code = ssh_exec(ip, cmd, nil, 20)
        unless exit_code.zero? && JSON.parse(stdout)
          raise "could not retrieve manifest checkpoints via #{cmd} on ip #{ip}, "\
                "last try failed with:\n#{stdout}\n#{stderr}\nstatus code: #{exit_code}"
        end
      end
    end
  end

  it 'verifies api secret checkpoints' do
    secrets = @cluster.secret_files('kube-system', 'kube-apiserver')

    @cluster.master_ip_addresses.each do |ip|
      path = '/etc/kubernetes/checkpoint-secrets/kube-system/kube-apiserver-*/kube-apiserver'
      cmd = secrets
            .map { |secret| "test -e #{path}/#{secret}" }
            .join(' && ')
      cmd = "sudo sh -c '#{cmd}'"

      Retriable.with_retries(limit: 20, sleep: 3) do
        stdout, stderr, exit_code = ssh_exec(ip, cmd, nil, 20)
        unless exit_code.zero?
          raise "could not retrieve secret checkpoints via #{cmd} on ip #{ip}, "\
                "last try failed with:\n#{stdout}\n#{stderr}\nstatus code: #{exit_code}"
        end
      end
    end
  end

  # Disabled because we are not idempotent
  xit 'terraform plan after a terraform apply is an idempotent operation (does not suggest further changes)' do
    # https://www.terraform.io/docs/commands/plan.html#detailed-exitcode
    options = '-detailed-exitcode'
    stdout, stderr, exit_status = @cluster.plan(options)
    puts stdout, stderr unless exit_status.eql?(0)
    expect(exit_status).to eq(0)
  end

  it 'succeeds with the golang test suit', :smoke_tests do
    expect { SmokeTest.run(@cluster) }.to_not raise_error
  end

  it 'installs the correct Container Linux version' do
    version = @cluster.tf_var('tectonic_container_linux_version')
    # version = @cluster.tf_value('module.container_linux.version') if version == 'latest'
    version = @cluster.tfstate_file.output('container_linux', 'version') if version == 'latest'
    expect(ContainerLinux.version(@cluster)).to eq(version)
  end

  it 'installs the correct Container Linux channel' do
    expect(ContainerLinux.channel(@cluster)).to eq(@cluster.tf_var('tectonic_container_linux_channel'))
  end

  # Disabled because the new flow using CLI does not support scale up for now
  xdescribe 'scale up worker cluster' do
    before(:all) do
      platform = @cluster.env_variables['PLATFORM']
      # remove platform AZURE when the JIRA https://jira.prod.coreos.systems/browse/INST-619 is fixed
      skip_platform = %w[metal azure gcp]
      skip "This test is not ready to run in #{platform}" if skip_platform.include?(platform)
      skip 'Skipping this tests. running locally' unless Jenkins.environment?
    end

    it 'can scale up nodes by 1 worker' do
      platform = @cluster.env_variables['PLATFORM']
      if platform.downcase.include?('aws')
        @cluster.config_file.add_worker_node(@cluster.config_file.worker_count + 1)
      else
        @cluster.tfvars_file.add_worker_node(@cluster.tfvars_file.worker_count + 1)
      end

      expect { @cluster.update_cluster }.to_not raise_error
    end
  end

  it 'passes the k8s conformance tests', :conformance_tests do
    conformance_test = TestContainer.new(
      ENV['KUBE_CONFORMANCE_IMAGE'],
      @cluster,
      vpn_tunnel
    )
    expect { conformance_test.run }.to_not raise_error
  end

  (ENV['COMPONENT_TEST_IMAGES'] || '').split(',').each do |image|
    it "passes component test '#{image}'", :component_tests do
      test_container = TestContainer.new(
        image.chomp,
        @cluster,
        vpn_tunnel
      )
      expect { test_container.run }.to_not raise_error
    end
  end
end

RSpec.shared_examples 'withPlannedCluster' do |tf_vars_path|
  before(:all) do
    @cluster = ClusterFactory.from_tf_vars(TFVarsFile.new(tf_vars_path))
  end

  it 'terraform plan succeeds' do
    stdout, stderr, exit_status = @cluster.plan
    puts "Terrform plan stdout:\n#{stdout}"
    puts "Terrform plan stderr:\n#{stderr}"
    expect(exit_status).to eq(0)
  end

  after(:all) do
    @cluster.stop
  end
end
