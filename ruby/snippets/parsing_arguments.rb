#!/usr/bin/env ruby

# Imports
require 'optparse'

# Hash for options
options = {}

# Parser object to get values from command line
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: parsing_args.rb [options]'

  opts.on('-f', '--first FIRST', Integer, 'First Number') do |first|
    options[:first] = first
  end

  opts.on('-s', '--second SECOND', Integer, 'Second Number') do |second|
    options[:second] = second
  end

  opts.on('-h', '--help', 'Print this help') do
    puts optparse
    exit
  end
end
optparse.parse!

# Throw exceptions if values are missing
raise OptionParser::MissingArgument, '-f is missing' if options[:first].nil?
raise OptionParser::MissingArgument, '-s is missing' if options[:second].nil?

puts options[:first] + options[:second]
