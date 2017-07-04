# EnvVars contains helper functions for system environment variables
module EnvVar
  def self.set?(vars)
    vars.all? { |cred| !ENV[cred].nil? }
  end
end
