#!/usr/bin/ruby

require 'aws-sdk'
require 'net/http'
require 'uri'

# AWS Config
Aws.config.update({
    region: 'us-east-1',
    credentials: Aws::SharedCredentials.new
})

# AWS SDK Client
ec2 = Aws::EC2::Client.new
resp = ec2.describe_instance_status()
count = 0

# Count up running instances from AWS output
resp.instance_statuses.each do |instance_status|
    if instance_status.instance_state.name == "running"
        count += 1
    end
end

# Tipboard Variables
apikey = ENV['TIPBOARD_API_KEY']
tipboard_base_uri = "http://localhost:7272/api/v0.1"

# Parameters for POST
push_data = '{"title": "Running Instances", "description": "Amazon Web Services", "just-value": "' + count.to_s + '"}'
push_params = {
    'tile' => 'just_value',
    'key'  => 'running_instances',
    'data' => "#{push_data}"
}


# Push URI
push_uri = URI.parse("#{tipboard_base_uri}/#{apikey}/push")

# Post to API to set up tile
push_response = Net::HTTP.post_form(push_uri, push_params)

# Pick color depending on number of instances
if count == 0
    tileconfig_data = '{}'
else
    tileconfig_data = '{"just-value-color": "green", "fading_background": false }'
end

# Tileconfig URI
tileconfig_uri = URI.parse("#{tipboard_base_uri}/#{apikey}/tileconfig/running_instances")
tileconfig_params = {
    'value' => "#{tileconfig_data}"
}

# Post to API to set up tileconfig
tileconfig_response = Net::HTTP.post_form(tileconfig_uri, tileconfig_params)
