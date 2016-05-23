provider "aws" {
  shared_credentials_file  = "${var.aws_credentials_file}"
  profile                  = "${var.aws_credentials_profile}"
  region                   = "${var.aws_region}"
}

resource "aws_vpc" "training" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "Training"
  }
}

resource "aws_internet_gateway" "training" {
  vpc_id = "${aws_vpc.training.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "dmz" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.dmz.id}"
  depends_on = ["aws_internet_gateway.training"]
}

resource "aws_eip" "nat_c" {
  vpc = true
}

resource "aws_nat_gateway" "dmz_c" {
  allocation_id = "${aws_eip.nat_c.id}"
  subnet_id = "${aws_subnet.dmz_c.id}"
  depends_on = ["aws_internet_gateway.training"]
}

resource "aws_subnet" "dmz" {
  vpc_id = "${aws_vpc.training.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-1a"
  tags {
    Name = "Training Public Subnet"
  }
}

resource "aws_subnet" "dmz_c" {
  vpc_id = "${aws_vpc.training.id}"
  cidr_block = "${var.public_subnet_cidr_c}"
  availability_zone = "eu-west-1c"
  tags {
    Name = "Training Public Subnet"
  }
}

resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.training.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.training.id}"
  }
  tags {
    Name = "Training route table dmz_to_intgw"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.training.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_route_table_association" "eu-west-1a-public" {
  subnet_id = "${aws_subnet.dmz.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_route_table_association" "eu-west-1c-public" {
  subnet_id = "${aws_subnet.dmz_c.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.training.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1a"
  tags {
    Name = "Training Private Subnet"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id = "${aws_vpc.training.id}"
  cidr_block = "${var.private_subnet_cidr_c}"
  availability_zone = "eu-west-1c"
  tags {
    Name = "Training Private Subnet"
  }
}

resource "aws_route_table" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.training.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.dmz.id}"
  }

  tags {
    Name = "Training route table prv_to_natgw"
  }
}

resource "aws_route_table_association" "eu-west-1a-private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}

resource "aws_route_table_association" "eu-west-1c-private" {
  subnet_id = "${aws_subnet.private_c.id}"
  route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}

resource "aws_security_group" "bastion" {
  name = "training-bastion"
  description = "Allow SSH traffic from the internet"
  vpc_id = "${aws_vpc.training.id}"

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


resource "aws_security_group" "allow_access_from_bastion" {
  name = "training-allow_access_from_bastion"
  vpc_id = "${aws_vpc.training.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}


resource "aws_instance" "bastion" {
  ami = "${lookup(var.amis, var.aws_region)}"
  instance_type = "t2.medium"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.dmz.id}"
  security_groups = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "training-bastion"
    Environment = "${var.environment}"
  }
}


resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

