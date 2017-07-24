# TFVarsFile represents a Terraform configuration file describing a Tectonic
# cluster configuration
class TFVarsFile
  attr_reader :path
  def initialize(file_path)
    @path = file_path
  end
end
