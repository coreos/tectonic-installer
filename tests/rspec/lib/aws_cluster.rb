# frozen_string_literal: true

require 'aws_region'
require 'json'
require 'jenkins'
require 'grafiti'
require 'env_var'
require 'aws_iam'
require 'aws_support'
require 'tfstate_file'
require 'fileutils'
require 'with_retries'
require 'cluster_support'
require 'kubectl_helpers'
require 'name_generator'
require 'password_generator'
require 'securerandom'
require 'ssh'
require 'tfvars_file'
require 'config_file'
require 'timeout'
require 'with_retries'
require 'open3'

# AWSCluster represents a k8s cluster on AWS cloud provider
class AwsCluster
  TIMEOUT_IN_SECONDS = (30 * 60).freeze # 30 minutes

  attr_reader :config_file, :kubeconfig, :manifest_path, :build_path,
              :tectonic_admin_email, :tectonic_admin_password, :tfstate

  def initialize(config_file)
    @config_file = config_file
    export_random_region_if_not_defined if Jenkins.environment?
    @aws_region = ENV['TF_VAR_tectonic_aws_region']

    @name = @config_file.cluster_name
    @build_path = File.join(File.dirname(ENV['RELEASE_TARBALL_PATH']), "tectonic-dev/#{@name}")
    @manifest_path = File.join(@build_path, 'generated')
    @kubeconfig = File.join(@build_path, 'generated/auth/kubeconfig')

    @role_credentials = nil
    @role_credentials = AWSIAM.assume_role(@aws_region) if ENV.key?('TECTONIC_INSTALLER_ROLE')

    unless ssh_key_defined?
      ENV['TF_VAR_tectonic_aws_ssh_key'] = AwsSupport.create_aws_key_pairs(@aws_region, @role_credentials)
    end

    @config_file.change_aws_region(@aws_region)
    @config_file.change_license(ENV['TF_VAR_tectonic_license_path'])
    @config_file.change_pull_secret(ENV['TF_VAR_tectonic_pull_secret_path'])
    @config_file.change_ssh_key(@config_file.platform, ENV['TF_VAR_tectonic_aws_ssh_key'])

    @tectonic_admin_email = NameGenerator.generate_fake_email if @config_file.admin_credentials[0].nil?
    @tectonic_admin_password = PasswordGenerator.generate_password if @config_file.admin_credentials[1].nil?
    @config_file.change_admin_credentials(@tectonic_admin_email, @tectonic_admin_password)

    @tfstate = {}
    @tfstate['masters'] = TFStateFile.new(@build_path, 'masters.tfstate')
    @tfstate['workers'] = TFStateFile.new(@build_path, 'joining_workers.tfstate')
    @tfstate['etcd'] = TFStateFile.new(@build_path, 'etcd.tfstate')
    @tfstate['topology'] = TFStateFile.new(@build_path, 'topology.tfstate')
  end

  def start
    apply
    wait_til_ready
  end

  def init
    env = env_variables
    env['TF_INIT_OPTIONS'] = '-no-color'

    run_tectonic_cli(env, 'init', '--config=config.yaml')
    # The config within the build folder is the source of truth after init
    @config_file = ConfigFile.new(File.expand_path("#{@name}/config.yaml"))
  end

  def update_cluster
    start
  end

  def stop
    if ENV['TF_VAR_tectonic_aws_ssh_key'].include?('rspec-')
      AwsSupport.delete_aws_key_pairs(ENV['TF_VAR_tectonic_aws_ssh_key'], @aws_region, @role_credentials)
    end

    if ENV.key?('TECTONIC_TESTS_DONT_CLEAN_UP')
      puts "*** Cleanup inhibiting flag set. Stopping here. ***\n"
      puts '*** Your email/password to use in the tectonic console is:'\
           "#{@tectonic_admin_email} / #{@tectonic_admin_password} ***\n"
      return
    end
    destroy
  end

  def check_prerequisites
    raise 'AWS credentials not defined' unless credentials_defined?
    raise 'TF_VAR_tectonic_aws_ssh_key is not defined' unless ssh_key_defined?
    raise 'TF_VAR_tectonic_aws_region is not defined' unless region_defined?

    return if license_and_pull_secret_defined?
    raise 'Tectonic license and pull secret are not defined as environment'\
          'variables.'
  end

  def region_defined?
    EnvVar.set?(%w[TF_VAR_tectonic_aws_region])
  end

  def credentials_defined?
    credential_names = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY]
    profile_name = %w[AWS_PROFILE]
    session_token = %w[
      AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY
      AWS_SESSION_TOKEN
    ]
    EnvVar.set?(credential_names) ||
      EnvVar.set?(profile_name) ||
      EnvVar.set?(session_token)
  end

  def ssh_key_defined?
    EnvVar.set?(%w[TF_VAR_tectonic_aws_ssh_key])
  end

  def recover_from_failed_destroy
    Grafiti.new(@build_path, ENV['TF_VAR_tectonic_aws_region']).clean
  end

  def env_variables
    variables = {}
    variables['CLUSTER'] = @name
    variables['TF_VAR_tectonic_cluster_name'] = @name
    variables['TF_VAR_tectonic_admin_email'] = @tectonic_admin_email
    variables['TF_VAR_tectonic_admin_password'] = @tectonic_admin_password
    variables['PLATFORM'] = 'aws'
    variables['TF_VAR_tectonic_cluster_name'] = @config_file.cluster_name
    variables['CLUSTER'] = @config_file.cluster_name

    # Unless base domain is provided by the user:
    unless ENV.key?('TF_VAR_tectonic_base_domain')
      variables['TF_VAR_tectonic_base_domain'] = 'tectonic-ci.de'
      @config_file.change_base_domain('tectonic-ci.de')
    end

    variables
  end

  def secret_files(namespace, secret)
    cmd = "get secret -n #{namespace} #{secret} -o go-template "\
          "\'--template={{range $key, $value := .data}}{{$key}}\n{{end}}\'"
    KubeCTL.run(@kubeconfig, cmd).split("\n")
  end

  def api_ip_addresses
    nodes = KubeCTL.run(
      @kubeconfig,
      'get node -l=node-role.kubernetes.io/master '\
      '-o jsonpath=\'{range .items[*]}'\
      '{@.metadata.name}{"\t"}{@.status.addresses[?(@.type=="ExternalIP")].address}'\
      '{"\n"}{end}\''
    )

    nodes = nodes.split("\n").map { |node| node.split("\t") }.to_h

    api_pods = KubeCTL.run(
      @kubeconfig,
      'get pod -n kube-system -l k8s-app=kube-apiserver '\
      '-o \'jsonpath={range .items[*]}'\
      '{@.metadata.name}{"\t"}{@.spec.nodeName}'\
      '{"\n"}{end}\''
    )

    api_pods
      .split("\n")
      .map { |pod| pod.split("\t") }
      .map { |pod| [pod[0], nodes[pod[1]]] }.to_h
  end

  def forensic(events = true)
    outputs_console_logs = machine_boot_console_logs
    outputs_console_logs.each do |ip, log|
      puts "saving boot logs from master-#{ip}"
      save_to_file(@name, 'console_machine', ip, 'console_machine', log)
    end

    save_kubernetes_events(@kubeconfig, @name) if events

    master_ip_addresses.each do |master_ip|
      save_docker_logs(master_ip, @name)

      ['bootkube', 'tectonic', 'kubelet', 'k8s-node-bootstrap'].each do |service|
        print_service_logs(master_ip, service, @name)
      end
    end

    worker_ip_addresses.each do |worker_ip|
      save_docker_logs(worker_ip, @name, master_ip_address)

      ['kubelet'].each do |service|
        print_service_logs(worker_ip, service, @name, master_ip_address)
      end
    end

    etcd_ip_addresses.each do |etcd_ip|
      ['etcd-member'].each do |service|
        print_service_logs(etcd_ip, service, @name, master_ip_address)
      end
    end
  end

  def machine_boot_console_logs
    instances_id = retrieve_instances_ids(@tfstate['masters'], 'module.masters.aws_autoscaling_group.masters')
    # Return the log output in a hash {ip => log}
    hash_log_ip = instances_id.map do |instance_id|
      {
        instance_id_to_ip_address(instance_id) =>
        AwsSupport.collect_ec2_console_logs(instance_id, @aws_region, @role_credentials)
      }
    end
    # convert the array to hash [{k1=>v1},{k2=>v2}] to {k1=>v1,k2=>v2}
    hash_log_ip.reduce({}, :update)
  end

  def retrieve_instances_ids(state_file, auto_scaling_groups)
    aws_autoscaling_group_master = state_file.value(auto_scaling_groups, 'id')
    AwsSupport.sorted_auto_scaling_instances(aws_autoscaling_group_master, @aws_region, @role_credentials)
  end

  def instance_id_to_ip_address(instance_id)
    AwsSupport.instance_ip_address(instance_id, @aws_region, @role_credentials)
  end

  def master_ip_addresses
    instances_id = retrieve_instances_ids(@tfstate['masters'], 'module.masters.aws_autoscaling_group.masters')
    instances_id.map { |instance_id| AwsSupport.instance_ip_address(instance_id, @aws_region, @role_credentials) }
  end

  def master_ip_address
    master_ip_addresses[0]
  end

  def worker_ip_addresses
    instances_id = retrieve_instances_ids(@tfstate['workers'], 'module.workers.aws_autoscaling_group.workers')
    instances_id.map { |instance_id| AwsSupport.instance_ip_address(instance_id, @aws_region, @role_credentials) }
  end

  def etcd_ip_addresses
    @tfstate['etcd'].output('etcd', 'ip_addresses')
  end

  private

  def license_and_pull_secret_defined?
    license_path = 'TF_VAR_tectonic_license_path'
    pull_secret_path = 'TF_VAR_tectonic_pull_secret_path'

    EnvVar.set?([license_path, pull_secret_path])
  end

  def apply
    Retriable.with_retries(limit: 3) do
      env = env_variables
      env['TF_APPLY_OPTIONS'] = '-no-color'
      env['TF_INIT_OPTIONS'] = '-no-color'

      run_tectonic_cli(env, 'install', "--dir=#{@name}")
    end
  end

  def destroy
    describe_network_interfaces
    Retriable.with_retries(limit: 3) do
      env = env_variables
      env['TF_DESTROY_OPTIONS'] = '-no-color'
      env['TF_INIT_OPTIONS'] = '-no-color'
      run_tectonic_cli(env, 'destroy', "--dir=#{@name}")
    end

    recover_from_failed_destroy
    raise 'Destroying cluster failed'
  rescue => e
    recover_from_failed_destroy
    raise e
  end

  def run_tectonic_cli(env, cmd, flags = '')
    tectonic_binary = File.join(
      File.dirname(ENV['RELEASE_TARBALL_PATH']),
      'tectonic-dev/installer/tectonic'
    )

    tectonic_logs = File.join(
      File.dirname(ENV['RELEASE_TARBALL_PATH']),
      "tectonic-dev/#{@name}/logs/tectonic-#{cmd}.log"
    )

    ::Timeout.timeout(TIMEOUT_IN_SECONDS) do
      command = "#{tectonic_binary} #{cmd} #{flags}"
      output = ''
      Open3.popen3(env, "bash -coxe pipefail '#{command}'") do |_stdin, stdout, stderr, wait_thr|
        puts "Only printing tectonic logs to stdout/stderr on failure for command: #{command}.\nLogs are preserved via log files."

        while (line = stdout.gets)
          output += line
        end
        while (line = stderr.gets)
          output += line
        end

        save_terraform_logs(tectonic_logs, output)
        unless wait_thr.value.success?
          puts output
          raise "failed to execute command: #{command}"
        end
      end
    end
  rescue Timeout::Error
    save_terraform_logs(tectonic_logs, output)
    forensic(false)
    raise 'Applying cluster failed'
  end

  def wait_nodes_ready
    from = Time.now
    loop do
      puts 'Waiting for nodes become in ready state after an update'
      Retriable.with_retries(KubeCTL::KubeCTLCmdError, limit: 5, sleep: 10) do
        nodes = describe_nodes
        nodes_ready = Array.new(@config_file.node_count, false)
        nodes['items'].each_with_index do |item, index|
          item['status']['conditions'].each do |condition|
            if condition['type'] == 'Ready' && condition['status'] == 'True'
              nodes_ready[index] = true
            end
          end
        end
        if nodes_ready.uniq.length == 1 && nodes_ready.uniq.include?(true)
          puts '**All nodes are Ready!**'
          return true
        end
        puts "One or more nodes are not ready yet or missing nodes. Waiting...\n" \
             "# of returned nodes #{nodes['items'].size}. Expected #{@config_file.node_count}"
        elapsed = Time.now - from
        raise 'waiting for all nodes to become ready timed out' if elapsed > 1200 # 20 mins timeout
        sleep 20
      end
    end
  end

  # TODO: (carlos) remove this
  def tf_var(v)
    tf_value "var.#{v}"
  end

  # TODO: (carlos) remove this
  def tf_value(v)
    Dir.chdir(@build_path) do
      `echo '#{v}' | terraform console ../steps/masters/aws`.chomp
    end
  end

  def describe_network_interfaces
    puts 'describing network interfaces for debugging purposes'
    vpc_id = @tfstate['topology'].value('module.vpc.aws_vpc.cluster_vpc', 'id')
    filter = "--filters=Name=vpc-id,Values=#{vpc_id}"
    region = "--region #{@aws_region}"

    # TODO: use aws sdk instead of command line
    success = system("aws ec2 describe-network-interfaces #{filter}  #{region}")
    raise 'failed to describe network interfaces by vpc' unless success

  # Do not fail build. This is only for debugging purposes
  rescue => e
    puts e
  end

  def save_terraform_logs(tectonic_logs, output)
    # Save output in logs/
    FileUtils.mkdir_p(File.dirname(tectonic_logs))
    save_to_file = File.open(tectonic_logs, 'a')
    save_to_file << output
    save_to_file.close
  end

  def wait_til_ready
    sleep_wait_for_reboot
    wait_for_bootstrapping

    from = Time.now
    loop do
      begin
        KubeCTL.run(@kubeconfig, 'cluster-info')
        break
      rescue KubeCTL::KubeCTLCmdError
        elapsed = Time.now - from
        raise 'kubectl cluster-info never returned with successful error code' if elapsed > 1200 # 20 mins timeout
        sleep 10
      end
    end

    wait_nodes_ready
  end

  def wait_for_bootstrapping
    ips = master_ip_addresses
    raise 'Empty master ips. Aborting...' if ips.empty?
    wait_for_service('bootkube', ips)
    wait_for_service('tectonic', ips)
    puts 'HOORAY! The cluster is up'
  end

  # Adding this sleep to wait for some time before we start ssh into the server
  # if we ssh during the reboot from torcx this might put the shutdown in a weird state
  # and that's might be the reason why we saw several connection timeouts in tests while spinning up a cluster
  def sleep_wait_for_reboot
    from = Time.now
    loop do
      elapsed = Time.now - from
      puts "Sleeping for 5 minutes. Remaining #{300 - elapsed} seconds. Giving some time to the server reboot."
      sleep 30
      break if elapsed > 300 # 5 mins timeout
    end
    puts 'Done. Lets check the cluster now...'
  end

  def wait_for_service(service, ips)
    from = Time.now

    ::Timeout.timeout(30 * 60) do # 30 minutes
      loop do
        return if service_finished_bootstrapping?(ips, service)

        elapsed = Time.now - from
        if (elapsed.round % 5).zero?
          puts "Waiting for bootstrapping of #{service} service to complete..."
          puts "Checked master nodes: #{ips}"
        end
        sleep 10
      end
    end
  rescue Timeout::Error
    puts 'Trying to collecting the logs...'
    forensic(false) # Call forensic to collect logs when service timeout
    raise "timeout waiting for #{service} service to bootstrap on any of: #{ips}"
  end

  def service_finished_bootstrapping?(ips, service)
    command = "systemctl is-active #{service} --quiet && [ $(systemctl show -p SubState --value #{service}) == \"exited\" ]"
    ips.each do |ip|
      finished = 1
      begin
        _, _, finished = ssh_exec(ip, command)
      rescue => e
        puts "failed to ssh exec on ip #{ip} with: #{e}"
      end

      if finished.zero?
        puts "#{service} service finished successfully on ip #{ip}"
        return true
      end
    end
    false
  end

  def describe_nodes
    KubeCTL.run_and_parse(@kubeconfig, 'get nodes')
  end
end
