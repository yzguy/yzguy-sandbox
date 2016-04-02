#!/usr/bin/env ruby

require 'aws-sdk'

# Make sure the current user running the script is jenkins
unless ENV['USER'] == 'jenkins'
  abort("ERROR: This script should only be run on/as the jenkins user")
end

# Create EC2 Client and get instance status
ec2 = Aws::EC2::Client.new(region: 'us-west-2')

action = ARGV[0]
scope = ARGV[1]

# List of instances to leave running
stopped_instances_to_skip = [
  "i-ed63482a"
]

# List of instances to leave running
running_instances_to_skip = [
  "i-ed63482a"
]

if action == "start"
#### START ####
  # Store stopped instances
  stopped_instances = []

  # Get instances
  resp = ec2.describe_instances()

  # Loop through array of instances
  resp.reservations.each do |reservation|
    reservation.instances.each do |instance|
      # Add instance id to list if it's stopped
      if instance.state.name == "stopped"
        stopped_instances.push(instance.instance_id)
      end
    end
  end

  # If a singular instance is specified then set it to be the only stopped instance 
  if scope != "all"
    if stopped_instances.include?(scope)
      stopped_instances = [scope]
    else
      abort("ERROR: Specified instance (#{scope}) was not in stopped instances list")
    end
  end

  # Delete instances in the skip list out of the stopped instances list
  stopped_instances.each do |instance_id|
    if stopped_instances_to_skip.include?(instance_id)
      stopped_instances.delete(instance_id)
    end
  end

  # If there are stopped instances start them
  unless stopped_instances.empty?
    running_instances = ec2.start_instances({
      instance_ids: stopped_instances,
    })

    # Print each stopped instance id or that none have been started
    running_instances.starting_instances.each do |starting_instance|
      puts "Instance #{starting_instance.instance_id} has been started"
    end
    puts "#{running_instances.starting_instances.count} instance(s) have been started, #{stopped_instances_to_skip.count} instance(s) have been skipped"
  else
    puts "0 instance(s) have been started, #{stopped_instances_to_skip.count} instance(s) have been skipped"
  end
elsif action == "stop"
#### STOP ####
  # Store running instances
  running_instances = []

    # Get all the instances statuses
  resp = ec2.describe_instance_status()

  # Loop through array of instances
  resp.instance_statuses.each do |instance_status|
    # Add instance id to list if it's running
    if instance_status.instance_state.name == "running"
      running_instances.push(instance_status.instance_id)
    end
  end

  # If a singular instance is specified then set it to be the only running instance
  if scope != "all"
    if running_instances.include?(scope)
      running_instances = [scope]
    else
      abort("ERROR: Specified instance (#{scope}) was not in the running instances list")
    end
  end

  # Delete instances in the skip list out of the running instances list
  running_instances.each do |instance_id|
    if running_instances_to_skip.include?(instance_id)
      running_instances.delete(instance_id)
    end
  end

  # If there are running instances stop them
  unless running_instances.empty?
    stopped_instances = ec2.stop_instances({
      instance_ids: running_instances,
    })

    # Print each stopped instance id or that none have been stopped
    stopped_instances.stopping_instances.each do |stopped_instance|
      puts "Instance #{stopped_instance.instance_id} has been stopped"
    end
    puts "#{stopped_instances.stopping_instances.count} instance(s) have been stopped, #{running_instances_to_skip.count} instance(s) have been skipped"
  else
    puts "0 instance(s) have been stopped, #{running_instances_to_skip.count} instance(s) have been skipped"
  end
else
  puts "Usage: control_instances.rb <stop|start> <all|instance-id>"
end
