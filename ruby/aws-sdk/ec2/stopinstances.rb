#!/usr/bin/ruby

require 'aws-sdk'

# AWS Configuration
Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::SharedCredentials.new
})

# Create EC2 Client and get instance status
ec2 = Aws::EC2::Client.new
resp = ec2.describe_instance_status()

# List of instances to leave running
instances_to_skip = [
  "i-8eb4bf77"
]

# Store running instances
running_instances = []

# Loop through array of instances
resp.instance_statuses.each do |instance_status|
  # Add instance id to list if it's running and not in the skip list
  if instance_status.instance_state.name == "running" && !instances_to_skip.include?(instance_status.instance_id)
    running_instances.push(instance_status.instance_id)
  end
end

unless running_instances.empty?
  stopped_instances = ec2.stop_instances({
      instance_ids: running_instances,
  })

  stopped_instances.stopping_instances.each do |stopped_instance|
    puts "Instance #{stopped_instance.instance_id} has been stopped"
  end
  puts "#{stopped_instances.stopping_instances.count} instance(s) have been stopped"
else
  puts "0 instance(s) have been stopped, #{instances_to_skip.count} has been skipped"
end
