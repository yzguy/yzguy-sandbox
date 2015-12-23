#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'aws-sdk'
require 'colorize'

instances_to_terminate = ARGV[0].to_i || 1

Aws.config.update({
    region: 'us-east-1',
    credentials: Aws::SharedCredentials.new
})

ec2 = Aws::EC2::Client.new
resp = ec2.describe_instance_status()
instances_terminated = 0

resp.instance_statuses.each do |instance_status|
    if instances_terminated < instances_to_terminate
        if instance_status.instance_state.name == "running"
            terminated_instances = ec2.terminate_instances({
                instance_ids: [instance_status.instance_id],
            })
            puts "Instance ".blue + "#{terminated_instances.terminating_instances[0].instance_id}".green + " has been terminated".blue
            instances_terminated += 1
        end
    end
end
