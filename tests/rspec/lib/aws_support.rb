# frozen_string_literal: true

require 'aws-sdk'

# Shared support code for AWS-based operations
#
module AwsSupport
  def self.sorted_auto_scaling_instances(aws_autoscaling_group_id, aws_region)
    aws = Aws::AutoScaling::Client.new(region: aws_region)
    resp = aws.describe_auto_scaling_groups(auto_scaling_group_names: [
                                              aws_autoscaling_group_id.to_s
                                            ])
    resp.auto_scaling_groups[0].instances.map(&:instance_id).sort
  end

  def self.preferred_instance_ip_address(instance_id, aws_region)
    aws = Aws::EC2::Client.new(region: aws_region)
    resp = aws.describe_instances(instance_ids: [instance_id.to_s])
    ssh_master_ip = if resp.reservations[0].instances[0].network_interfaces[0].association.nil?
                      resp.reservations[0].instances[0].network_interfaces[0].private_ip_address
                    else
                      resp.reservations[0].instances[0].network_interfaces[0].association.public_ip
                    end
    ssh_master_ip
  end
end
