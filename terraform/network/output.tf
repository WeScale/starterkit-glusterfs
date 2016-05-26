output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "bastion_zone_a_ip" {
  value = "${module.bastion_zone_a.public_ip}"
}

output "bastion_zone_c_ip" {
  value = "${module.bastion_zone_c.public_ip}"
}

output "bastion_realm_security_group" {
  value = "${aws_security_group.bastion_realm.id}"
}
