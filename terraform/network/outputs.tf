output "vpc_cidr" {
  value = "${aws_vpc.training.cidr_block}"
}

output "vpc_id" {
  value = "${aws_vpc.training.id}"
}

output "dmz_a_id" {
  value = "${aws_subnet.dmz.id}"
}

output "dmz_a_cidr" {
  value = "${aws_subnet.dmz.cidr_block}"
}

output "dmz_c_id" {
  value = "${aws_subnet.dmz_c.id}"
}

output "dmz_c_cidr" {
  value = "${aws_subnet.dmz_c.cidr_block}"
}

output "back_a_cidr" {
  value = "${aws_subnet.private.cidr_block}"
}

output "back_c_cidr" {
  value = "${aws_subnet.private_c.cidr_block}"
}

output "subnet_back_a_id" {
  value = "${aws_subnet.private.id}"
}

output "subnet_back_c_id" {
  value = "${aws_subnet.private_c.id}"
}

output "sg_allow_bastion" {
  value = "${aws_security_group.allow_access_from_bastion.id}"
}

output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "bastion_realm_security_group" {
  value = "${aws_security_group.allow_access_from_bastion.id}"
}
