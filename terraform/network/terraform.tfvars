aws_region = "eu-west-1"

vpc_name = "LAB"
vpc_cidr = "10.42.0.0/16"
keypair = "training-ansible"

# AZ 1
public_subnet_cidr_1 = "10.42.1.0/24"
private_subnet_cidr_1 = "10.42.10.0/24"

# AZ 2
public_subnet_cidr_2 = "10.42.2.0/24"
private_subnet_cidr_2 = "10.42.20.0/24"

amis.eu-west-1 = "ami-e079f893"
