#!/usr/bin/env ruby

require 'aws-sdk'
require 'net/http'
require 'uri'

# Tipboard Variables
$apikey = ENV['TIPBOARD_API_KEY']
$tipboard_base_uri = "http://dockhost01.yzguy.io:7272/api/v0.1"

# AWS Config
Aws.config.update({
    region: 'us-east-1',
    credentials: Aws::SharedCredentials.new
})

# AWS SDK Client
$ec2 = Aws::EC2::Client.new

# Push data to Tipboard
def push_data(push_params)
    # Push URI
    push_uri = URI.parse("#{$tipboard_base_uri}/#{$apikey}/push")

    # Post to API to set up tile
    push_response = Net::HTTP.post_form(push_uri, push_params)
end

# Push Tileconfig to tipboard
def push_tileconfig(tile_name, tileconfig_params)
    # Tileconfig URI
    tileconfig_uri = URI.parse("#{$tipboard_base_uri}/#{$apikey}/tileconfig/" + tile_name)

    # Post to API to set up tileconfig
    tileconfig_response = Net::HTTP.post_form(tileconfig_uri, tileconfig_params)
end

def aws_running_instances()
    resp = $ec2.describe_instance_status()
    count = 0

    # Count up running instances from AWS output
    resp.instance_statuses.each do |instance_status|
        if instance_status.instance_state.name == "running"
            count += 1
        end
    end

    # Parameters for POST
    push_data = '{"title": "Running Instances", "description": "Amazon Web Services", "just-value": "' + count.to_s + '"}'
    push_params = {
        'tile' => 'just_value',
        'key'  => 'running_instances',
        'data' => "#{push_data}"
    }

    # Push data to tipboard
    push_data(push_params)

    if count > 0
      tileconfig_data = '{"just-value-color": "green", "fading_background": false }'
    else
      tileconfig_data = '{}'
    end

    # Tileconfig URI
    tileconfig_name = "running_instances"
    tileconfig_params = {
        'value' => "#{tileconfig_data}"
    }

    # Push Tileconfig to tipboard
    push_tileconfig(tileconfig_name, tileconfig_params)
end

def aws_terminated_instances()
  resp = $ec2.describe_instances()
  count = 0

  # Count up running instances from AWS output
  resp.reservations.each do |reservation|
      reservation.instances.each do |instance|
          if instance.state.name == "terminated"
              count += 1
          end
      end
  end

  # Parameters for POST
  push_data = '{"title": "Terminated Instances", "description": "Amazon Web Services", "just-value": "' + count.to_s + '"}'
  push_params = {
      'tile' => 'just_value',
      'key'  => 'terminated_instances',
      'data' => "#{push_data}"
  }

  # Push data to tipboard
  push_data(push_params)

  # Pick color depending on number of instances
  if count > 0
    tileconfig_data = '{"just-value-color": "red", "fading_background": false }'
  else
    tileconfig_data = '{}'
  end

  # Tileconfig URI
  tileconfig_name = "terminated_instances"
  tileconfig_params = {
      'value' => "#{tileconfig_data}"
  }

  # Push Tileconfig to tipboard
  push_tileconfig(tileconfig_name, tileconfig_params)
end

while true
    aws_running_instances
    sleep(5)
    aws_terminated_instances
    sleep(5)
end
