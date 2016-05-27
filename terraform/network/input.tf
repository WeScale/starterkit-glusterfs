variable "aws_region" {}

variable "vpc_cidr" {}

variable "vpc_name" {}

variable "amis" {
  default = {
    eu-west-1 = "ami-e079f893"
  }
}

variable "az_1" {}
variable "public_subnet_cidr_1" {}
variable "private_subnet_cidr_1" {}

variable "az_2" {}
variable "public_subnet_cidr_2" {}
variable "private_subnet_cidr_2" {}

variable "keypair" {}
