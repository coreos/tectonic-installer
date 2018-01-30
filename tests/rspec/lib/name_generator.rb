# frozen_string_literal: true

require 'jenkins'
require 'faker'

# NameGenerator contains helper functions to generate test resource names
module NameGenerator
  MAX_NAME_LENGTH = 28
  RANDOM_HASH_LENGTH = 5

  def self.generate(prefix)
    name = if Jenkins.environment?
             jenkins_env_name(prefix)
           else
             local_env_name
           end
    name.downcase
  end

  def self.jenkins_env_name(prefix)
    build_id = ENV['BUILD_ID']
    # Resource names containing dots are prohibited on most cloud providers
    branch_name = ENV['BRANCH_NAME'].to_s.delete('.')
    short_prefix = prefix.split('-').map { |x| x[0...3] }.join.gsub(/^(.{10,}?).*$/m, '\1')
    name = "#{short_prefix}-#{branch_name}-#{build_id}"
    name = name[0..(MAX_NAME_LENGTH - RANDOM_HASH_LENGTH - 1)]
    name += SecureRandom.hex[0...RANDOM_HASH_LENGTH]
    name
  end

  def self.local_env_name
    unless  ENV.key?('CLUSTER')
      raise 'Please define the CLUSTER environment variable '\
            'in a local test setup e.g. '\
            '`export CLUSTER=my-cluster-name`'
    end
    ENV['CLUSTER']
  end

  def self.generate_fake_email
    Faker::Internet.email
  end

  def self.generate_short_name
    "rspec-#{Faker::Internet.user_name(5..8)}-#{SecureRandom.hex[0...RANDOM_HASH_LENGTH]}"
  end
end
