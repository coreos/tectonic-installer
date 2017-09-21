# frozen_string_literal: true

# Operators contains helper functions to test creation of the CoreOS operators
module Operators
  DEFAULT_OPERATOR_PATH = 'tectonic/updater/operators'
  KVO_PATH = 'manifests'
  OPERATOR_NAMES = [
    'kube-version-operator',
    'tectonic-channel-operator',
    'tectonic-cluo-operator',
    'tectonic-etcd-operator',
    'tectonic-prometheus-operator'
  ].freeze

  def self.manifests_generated?(manifest_path)
    OPERATOR_NAMES.each do |operator_name|
      operator_path = operator_name == 'kube-version-operator' ? KVO_PATH : DEFAULT_OPERATOR_PATH
      file_path = File.join(
        manifest_path, operator_path, "#{operator_name}.yaml"
      )
      next if File.exist?(file_path)

      raise "could not find manifest for #{operator_name}"
    end
  end
end
