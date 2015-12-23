###### AWS Provider ######
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_record" "www" {
    domain = "${var.digitalocean.domain}"
    type = "CNAME"
    name = "www"
    value = "${aws_elb.dubdubdub.dns_name}."
}

###### VPC ######
resource "aws_vpc" "devvpc" {
    cidr_block = "${var.vpc.cidr_block}"
    enable_dns_support = "${var.vpc.enable_dns_support}"
    enable_dns_hostnames = "${var.vpc.enable_dns_hostnames}"
    tags {
        Name = "${var.vpc.name}"
    }
}

###### Internet Gateway ######
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.devvpc.id}"
    tags {
        Name = "${var.igw.name}"
    }
}

###### NAT Instance ######
resource "aws_instance" "nat" {
    instance_type = "${var.nat.instance_type}"
    ami = "${lookup(var.nat_amis, var.aws_region)}"
    key_name = "${var.key_name}"    
    source_dest_check = "false"
    subnet_id = "${aws_subnet.pub_sub.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    tags {
        Name = "${var.nat.name}"
    }
}

###### Public Subnet ######
resource "aws_subnet" "pub_sub" {
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "${var.pub_sub.cidr_block}"
    tags {
        Name = "${var.pub_sub.name}"
    }
}

###### Public Route Table ######
resource "aws_route_table" "pub_rt_table" {
    vpc_id = "${aws_vpc.devvpc.id}"
    route {
        cidr_block = "${var.pub_rt.defaultgw}"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
    tags {
        Name = "${var.pub_rt.name}"
    }
}

###### Public Route Table Association ######
resource "aws_route_table_association" "pub_rt_table_assoc" {
    subnet_id = "${aws_subnet.pub_sub.id}"
    route_table_id = "${aws_route_table.pub_rt_table.id}"
}

###### Private Subnet ######
resource "aws_subnet" "priv_sub" {
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "${var.priv_sub.cidr_block}"
    tags {
        Name = "${var.priv_sub.name}"
    }
}

###### Private Route Table ######
resource "aws_route_table" "priv_rt_table" {
    vpc_id = "${aws_vpc.devvpc.id}"
    route {
        cidr_block = "${var.priv_rt.defaultgw}"
        instance_id = "${aws_instance.nat.id}"
    }
    tags {
        Name = "${var.priv_rt.name}"
    }
}

###### Private Route Table Association ######
resource "aws_route_table_association" "priv_rt_table_assoc" {
    subnet_id = "${aws_subnet.priv_sub.id}"
    route_table_id = "${aws_route_table.priv_rt_table.id}"
}

###### VPC Network ACL ######
resource "aws_network_acl" "default" {
    vpc_id = "${aws_vpc.devvpc.id}"
    subnet_ids = ["${aws_subnet.pub_sub.id}","${aws_subnet.priv_sub.id}"]
    ingress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    egress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}

###### VPC Security Group ######
resource "aws_security_group" "default" {
    vpc_id = "${aws_vpc.devvpc.id}"
    name = "ip any any"
    description = "allow everything in and out"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

###### Elastic Load Balancer ######
resource "aws_elb" "dubdubdub" {
    name = "${var.elb.name}"
    security_groups = ["${aws_security_group.default.id}"]
    subnets = ["${aws_subnet.pub_sub.id}"]
    listener {
        instance_port = "${var.elb.instance_port}"
        instance_protocol = "${var.elb.instance_protocol}"
        lb_port = "${var.elb.lb_port}"
        lb_protocol = "${var.elb.lb_protocol}"
    }
    health_check {
        healthy_threshold = "${var.elb.hc_healthy_threshold}"
        unhealthy_threshold = "${var.elb.hc_unhealthy_threshold}"
        timeout = "${var.elb.hc_timeout}"
        target = "${var.elb.hc_target}"
        interval ="${var.elb.hc_interval}"
    }
    instances = ["${aws_instance.pub1.id}", "${aws_instance.pub2.id}"]
    tags {
        Name = "${var.elb.name}"
    }
}

###### EC2 Instances ######
resource "aws_instance" "pub1" {
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.pub_sub.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    connection {
        user = "ec2-user"
        key_file = "${var.key_file}"
    }
    tags {
        Name = "pub1"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y httpd",
            "sudo service httpd start",
            "sudo bash -c 'echo pub1 > /var/www/html/index.html'"
        ]
    }
}

resource "aws_instance" "pub2" {
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.pub_sub.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    connection {
        user = "ec2-user"
        key_file = "${var.key_file}"
    }
    tags {
        Name = "pub2"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y httpd",
            "sudo service httpd start",
            "sudo bash -c 'echo pub2 > /var/www/html/index.html'"
        ]
    }
}

resource "aws_instance" "priv1" {
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.priv_sub.id}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    connection {
        user = "ec2-user"
        key_file = "${var.key_file}"
    }
    tags {
        Name = "priv1"
    }
}
