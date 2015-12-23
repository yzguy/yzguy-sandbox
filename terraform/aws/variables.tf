###### Global variables ######
variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "do_token" { }
variable "key_file" { }
variable "key_name" { }

variable "digitalocean" {
    default = {
        domain = "yzguy.xyz"
    }
}

variable "aws_region" {
    description = "AWS region to launch compute resources in"
    default = "us-east-1"
}

variable "aws_amis" {
    default = {
        us-east-1 = "ami-1ecae776"
        us-west-1 = "ami-d114f295"
        us-west-2 = "ami-e7527ed7"
    }
}

variable "instance_type" { 
    default = "t2.micro"
}

###### VPC Variables ######
variable "vpc" {
    default = {
        cidr_block = "10.10.0.0/16"
        enable_dns_support = "true"
        enable_dns_hostnames = "true"
        name = "Dev VPC"
    }
}

###### Internet Gateway ######
variable "igw" {
    default = {
        name = "Internet Gateway"
    }
}

###### NAT Instance ######
variable "nat_amis" {
    default {
        us-east-1 = "ami-184dc970"
        us-west-1 = "ami-1d2b2958"
        us-west-2 = "ami-290f4119"
    }
}

variable "nat" {
    default = {
        instance_type = "t2.micro"
        name = "nat"
    }
}

###### Subnet Variables ######
###### Public Subnet ######
variable "pub_sub" {
    default = {
        cidr_block = "10.10.0.0/24"
        name = "Public Subnet"
    }
}

###### Public Route Table ######
variable "pub_rt" {
    default = {
        defaultgw = "0.0.0.0/0"
        name = "Public Route Table"
    }
}

###### Private Subnet ######
variable "priv_sub" {
    default = {
        cidr_block = "10.10.10.0/24"
        name = "Private Subnet"
    }
}

###### Private Route Table ######
variable "priv_rt" {
    default = {
        defaultgw = "0.0.0.0/0"
        name = "Private Route Table"
    }
}

###### Elastic Load Balancer ######
variable "elb" {
    default {
        name = "dubdubdub-yzguy-io-elb"
        instance_port = "80"
        instance_protocol = "http"
        lb_port = "80"
        lb_protocol = "http"
        hc_healthy_threshold = 2
        hc_unhealthy_threshold = 3
        hc_timeout = 3
        hc_target = "HTTP:80/"
        hc_interval = 30
    }
}

###### EC2 Instances ######

