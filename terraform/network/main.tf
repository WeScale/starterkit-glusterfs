provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "GlusterFS-Lab"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
  tags {
    Name = "Main route table for GlusterFS-Lab VPC"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main.id}"
}

module "zone_a" {
  source = "./az_perimeter"

  label = "zone_a"
  availability_zone = "eu-west-1a"
  public_subnet_cidr = "${var.public_subnet_cidr_a}"
  private_subnet_cidr = "${var.private_subnet_cidr_a}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
  vpc_id = "${aws_vpc.vpc.id}"
  bastion_ami_id = "ami-e079f893"
  bastion_instance_type = "t2.medium"
  bastion_keypair = "${var.aws_key_name}"
  bastion_security_group = "${aws_security_group.bastions.id}"
}

module "zone_c" {
  source = "./az_perimeter"

  label = "zone_c"
  availability_zone = "eu-west-1c"
  public_subnet_cidr = "${var.public_subnet_cidr_c}"
  private_subnet_cidr = "${var.private_subnet_cidr_c}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
  vpc_id = "${aws_vpc.vpc.id}"
  bastion_ami_id = "ami-e079f893"
  bastion_instance_type = "t2.medium"
  bastion_keypair = "${var.aws_key_name}"
  bastion_security_group = "${aws_security_group.bastions.id}"
}

resource "aws_security_group" "bastions" {
  name = "bastions"
  description = "Allow SSH traffic from the internet"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_realm" {
  name = "bastion_realm"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastions.id}"]
  }
}
