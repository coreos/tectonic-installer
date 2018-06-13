# frozen_string_literal: true

require 'fileutils'
require 'name_generator'

RSpec.shared_examples 'withBuildFolderSetupWithConfig' do |config_path|
  before(:all) do
    Dir.chdir(File.join(File.dirname(ENV['RELEASE_TARBALL_PATH']), 'tectonic-dev'))
    temp_config_file = ConfigFile.new(config_path)
    @name = ENV['CLUSTER'] || NameGenerator.generate(temp_config_file.prefix)
    ENV['CLUSTER'] = @name

    FileUtils.cp(
      config_path,
      'config.yaml'
    )
    @config_file = ConfigFile.new(File.expand_path('config.yaml'))
    @config_file.change_cluster_name(@name)
  end
end
