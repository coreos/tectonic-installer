# The AWSIAM contains helper functions to interact with AWS IAM
module AWSIAM
  def self.assume_role
    role_name = ENV['TECTONIC_INSTALLER_ROLE']

    role_arn = JSON.parse(
      `aws iam get-role --role-name="#{role_name}"`
    )['Role']['Arn']

    credentials = request_credentials(role_arn)

    ENV['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
    ENV['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
    ENV['AWS_SESSION_TOKEN'] = credentials['SessionToken']
  end

  def self.request_credentials(role_arn)
    cmd = "aws sts assume-role --role-arn='#{role_arn}'"\
          ' --role-session-name=tectonic-installer'
    JSON.parse(`#{cmd}`)['Credentials']
  end
end
