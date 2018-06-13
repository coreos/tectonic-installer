# frozen_string_literal: true

require 'shared_examples/build_folder_setup'
require 'smoke_test'
require 'aws_cluster'
require 'operators'
require 'name_generator'
require 'password_generator'
require 'test_container'
require 'with_retries'
require 'jenkins'

RSpec.shared_examples 'withRunningClusterExistingBuildFolder' do |vpn_tunnel = false, exist_plat = nil, exist_cfg_file = nil|
  before(:all) do
    # See https://stackoverflow.com/a/45936219/4011134
    @exceptions = []

    @cluster = AwsCluster.new(@config_file)
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

  it 'succeeds with the golang test suit', :smoke_tests do
    expect { SmokeTest.run(@cluster) }.to_not raise_error
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
