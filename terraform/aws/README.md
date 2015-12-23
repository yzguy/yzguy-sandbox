terraform-aws-sandbox
=====================
Just me messing around learing Hashicorp's terraform.

This will created
* VPC
* Internet Gateway
* NAT instance
* Public Subnet
* Public Route Table
* Public Route Table Association
* Private Subnet
* Private Route Table
* Private Route Table Association
* Network ACL
* Security Group
* Elastic Load Balancer
* 2 x EC2 instance in public subnet
* 1 x EC2 instance in private subnet
* Update DigitalOcean DNS to point at ELB VIP

It uses a variables file to hold things from names, instance types, cidr blocks, etc, so they are abstracted away from the configuration

It also uses tfvar file to hold sensitive data like AWS Access/Secret keys and key location/name

