output "elb_dns" {
    value = "${aws_elb.dubdubdub.dns_name}"
}

output "nat_dns" {
    value = "${aws_instance.nat.dns_name}"
}

output "pub1_dns" {
    value = "${aws_instance.pub1.dns_name}"
}

output "pub2_dns" {
    value = "${aws_instance.pub1.dns_name}"
}
