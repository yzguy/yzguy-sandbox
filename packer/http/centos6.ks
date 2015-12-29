install
cdrom
skipx
text
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto dhcp --noipv6
rootpw --plaintext password
firewall --disable
authconfig --enableshadow --passalgo=sha512
selinux --disable
timezone --utc America/New_York
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"

reboot

# Disk Partitioning
zerombr
clearpart --all --initlabel 

part /boot --fstype=ext4 --asprimary --size=500
part pv.008002 --grow --asprimary --size=200

volgroup rootvg --pesize=4096 pv.008002
logvol /opt --fstype=ext4 --name=optvol --vgname=rootvg --size=11784
logvol / --fstype=ext4 --name=rootvol --vgname=rootvg --size=6144
logvol swap --name=swapvol --vgname=rootvg --size=2048

%packages --nobase
@core
%end
