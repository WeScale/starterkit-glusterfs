###############################################################################
# PROVIDER
###############################################################################

provider "aws" {}

variable "name" {}

variable "vpc_cidr" {}

variable "public_subnet_cidr" {}

variable "availability_zone" {}


###############################################################################
# COMPONENTS
###############################################################################

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "Packer public subnet"
  }
}

resource "aws_security_group" "packer-amis" {
  name = "packer-amis"
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
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "Main route table for NewVizzboard VPC"
  }
}

resource "aws_iam_role" "ami_building_role" {
  name = "ami_building_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ami_building_policy" {

  name = "ami_building_policy"

  role = "${aws_iam_role.ami_building_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ami_building_instance_profile" {
  name = "ami_building_instance_profile"
  roles = ["${aws_iam_role.ami_building_role.name}"]
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main.id}"
}

output vpc_id {
  value = "${aws_vpc.vpc.id}"
}

output security_group_id {
  value = "${aws_security_group.packer-amis.id}"
}

output subnet_id {
  value = "${aws_subnet.public_subnet.id}"
}
