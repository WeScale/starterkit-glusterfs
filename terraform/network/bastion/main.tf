
variable "bastion_subnet_id" {}
variable "bastion_ami_id" {}
variable "bastion_instance_type" {}
variable "bastion_keypair" {}
variable "bastion_security_group" {}

resource "aws_instance" "bastion" {
  ami = "${var.bastion_ami_id}"
  instance_type = "${var.bastion_instance_type}"
  key_name = "${var.bastion_keypair}"
  subnet_id = "${var.bastion_subnet_id}"
  security_groups = ["${var.bastion_security_group}"]

  tags {
    Name = "Bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

output "public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
