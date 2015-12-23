#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'aws-sdk'
require 'colorize'

num_of_instances = ARGV[0] || 1

Aws.config.update({
    region: 'us-east-1',
    credentials: Aws::SharedCredentials.new
})

ec2 = Aws::EC2::Client.new

reservations = ec2.run_instances({
    image_id: "ami-1ecae776",
    min_count: 1,
    max_count: num_of_instances.to_i,
    key_name: "yzguy",
    instance_type: "t2.micro",
    monitoring: {
        enabled: true,
    },
    network_interfaces: [
        {
            device_index: 0,
            subnet_id: "subnet-1c87b337",
            groups: ["sg-d1d672b7"],
            associate_public_ip_address: true,
        }
    ]
})

reservations.instances.each do |instance|
    puts "Instance ".blue + "#{instance.instance_id}".green + " has been created".blue
end
