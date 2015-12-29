# Install Operating System from CD
install
cdrom

# Do not configure X
skipx

# Perform Kickstart Installation in Text Mode
text

# Set Installation/Default Langauge
lang en_US.UTF-8

# Set Keyboard Layout
keyboard us

# Configure network information 
# onboot - enable or disable device at boot
# device - specify device to be configured
# bootproto - protocol to boot (dhcp, static)
# noipv6 - Disable ipv6 on this device
network --onboot yes --device eth0 --bootproto dhcp --noipv6

# Set root password
rootpw --plaintext password

# Disable iptables
firewall --disable

# Set up authentication options
# enableshadow - use shadow passwords
# passalgo - password algorithm
authconfig --enableshadow --passalgo=sha512

# Set selinux to disable
selinux --disable

# Set the system timezone 
timezone --utc America/New_York

# Specify how boot loader should be installed
# location - specify where boot record is written
# driveorder - specify which drive is first in BIOS boot order
# append - additional kernel parameters
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"

# Reboot after installation is successful
reboot

# Initialize invalid partition tables
zerombr

# Remove partitions from system
# all - remove all partitions
# initlabel - initialize disklabel
clearpart --all --initlabel 

# Create boot partition 
# fstype - set filesystem type
# asprimary - set as primary partition
# size - set size in MB
part /boot --fstype=ext4 --asprimary --size=500

# Create physical volume with id 008002
# grow - grow to fill available space
# asprimary - set as primary partition
# size - minimum partition size
part pv.008002 --grow --asprimary --size=200

# Create volume group with name rootvg
# pesize - set the volume groups physical extends (4096 = 4 MiB)
# use physical volume with id 008002
volgroup rootvg --pesize=4096 pv.008002

# Create logical volume /opt, /, swap
# fstype - set filesystem type
# name - set name of logical volume
# vgname - volume group for logical volume to be in
# size - size of logical volume
logvol /opt --fstype=ext4 --name=optvol --vgname=rootvg --size=11784
logvol / --fstype=ext4 --name=rootvol --vgname=rootvg --size=6144
logvol swap --name=swapvol --vgname=rootvg --size=2048

# Software packages to be installed
%packages --nobase
@core
%end
