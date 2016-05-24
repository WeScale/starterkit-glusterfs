
variable "label" {}
variable "availability_zone" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "public_gateway_route_table_id" {}
variable "bastion_ami_id" {}
variable "bastion_instance_type" {}
variable "bastion_keypair" {}
variable "bastion_security_group" {}
variable "vpc_id" {}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "${var.label} public subnet"
  }
}

resource "aws_eip" "nat_instance" {
  vpc = true
}

resource "aws_nat_gateway" "nat_instance" {
  allocation_id = "${aws_eip.nat_instance.id}"
  subnet_id = "${aws_subnet.public_subnet.id}"
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1c"
  tags {
    Name = "Training Private Subnet"
  }
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_instance.id}"
  }

  tags {
    Name = "${var.label} private subnet route table"
  }
}

resource "aws_route_table_association" "private_subnet_to_nat" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_subnet_route.id}"
}

resource "aws_route_table_association" "public_subnet_to_gateway" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${var.public_gateway_route_table_id}"
}


resource "aws_instance" "bastion" {
  ami = "${var.bastion_ami_id}"
  instance_type = "${var.bastion_instance_type}"
  key_name = "${var.bastion_keypair}"
  subnet_id = "${aws_subnet.public_subnet.id}"
  security_groups = ["${var.bastion_security_group}"]

  tags {
    Name = "${var.label}_bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}