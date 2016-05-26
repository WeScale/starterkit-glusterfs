provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.vpc_name}"
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
    Name = "Main route table for ${var.vpc_name} VPC"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main.id}"
}

module "zone_a" {
  source = "github.com/WeScale/terraform-aws-az"

  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.vpc_name}"
  availability_zone = "eu-west-1a"
  public_subnet_cidr = "${var.public_subnet_cidr_1}"
  private_subnet_cidr = "${var.private_subnet_cidr_1}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}

module "bastion_zone_a" {
  source = "github.com/WeScale/tf-mod-aws-az-bastion"

  name = "eu-west-1a"
  ami_id = "ami-e079f893"
  subnet_id = "${module.zone_a.public_subnet_id}"
  instance_type = "t2.medium"
  keypair = "${var.keypair}"
  security_groups = "${aws_security_group.bastions.id}"
}


module "zone_c" {
  source = "github.com/WeScale/terraform-aws-az"

  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.vpc_name}"
  availability_zone = "eu-west-1c"
  public_subnet_cidr = "${var.public_subnet_cidr_2}"
  private_subnet_cidr = "${var.private_subnet_cidr_2}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}

module "bastion_zone_c" {
  source = "github.com/WeScale/tf-mod-aws-az-bastion"

  name = "eu-west-1c"
  ami_id = "ami-e079f893"
  subnet_id = "${module.zone_c.public_subnet_id}"
  instance_type = "t2.medium"
  keypair = "${var.keypair}"
  security_groups = "${aws_security_group.bastions.id}"
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


