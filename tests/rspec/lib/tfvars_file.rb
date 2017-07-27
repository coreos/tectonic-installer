require 'json'

# TFVarsFile represents a Terraform configuration file describing a Tectonic
# cluster configuration
class TFVarsFile
  attr_reader :path, :json
  def initialize(file_path)
    @path = file_path
    raise "file #{file_path} does not exist" unless file_exists?
    @json = JSON.parse(File.read(path))
  end

  def experimental?
    json['tectonic_experimental'] == 'true'
  end

  def calico?
    json['tectonic_calico_network_policy'] == 'true'
  end

  def node_count
    master_count + worker_count
  end

  private

  def master_count
    json['tectonic_master_count'].to_i
  end

  def worker_count
    json['tectonic_worker_count'].to_i
  end

  def file_exists?
    File.exist? path
  end
end
