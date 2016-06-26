require 'ipaddr'

nyc      = IPAddr.new('10.133.0.0/16')
san_fran = IPAddr.new('10.142.0.0/16')
cloud    = IPAddr.new('10.10.10.0/24')

Facter.add('node_location') do
  node_location = 'Chicago'
  setcode do
    interfaces = Facter.value(:interfaces)
    interfaces_array = interfaces.split(',')

    interfaces_array.each do |interface|
      ipaddress = Facter.value("ipaddress_#{interface}")
      node_location = 'NYC' if nyc.include?(ipaddress)
      node_location = 'San Francisco' if san_fran.include?(ipaddress)
      node_location = 'AWS' if cloud.include?(ipaddress)
    end
    node_location
  end
end
