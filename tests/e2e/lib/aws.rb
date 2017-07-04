require 'env_var'

# AWS contains helper functions for the AWS cloud provider
module AWS
  def self.check_prerequisites
    credential_names = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY]
    raise 'AWS credentials are not defined.' unless
      EnvVar.set?(credential_names)

    raise 'TF_VAR_tectonic_aws_ssh_key is not defined' unless
      EnvVar.set?(['TF_VAR_tectonic_aws_ssh_key'])
  end
end
