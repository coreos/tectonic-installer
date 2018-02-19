# frozen_string_literal: true

require 'fileutils'
require 'name_generator'

RSpec.shared_examples 'withBuildFolderSetup' do |tf_vars_path|
  before(:all) do
    Dir.chdir(File.join(File.dirname(ENV['RELEASE_TARBALL_PATH']), 'tectonic'))
    # TODO: Only ignore on AWS
    # temp_tfvars_file = TFVarsFile.new(tf_vars_path)
    # @name = ENV['CLUSTER']
    # ENV['CLUSTER'] = @name

    # TODO: Only ignore on AWS
    # file_path = "build/#{@name}"
    # FileUtils.mkdir_p file_path
    # Dir.chdir(file_path)

    FileUtils.cp(
      tf_vars_path,
      'config.yaml'
    )
    # @tfvars_file = TFVarsFile.new(File.expand_path('terraform.tfvars'))
  end
end
