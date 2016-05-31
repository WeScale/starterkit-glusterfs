variable "aws_region" {}

variable "vpc_cidr" {}

variable "vpc_name" {}

variable "amis" {
  default = {
    eu-west-1 = "ami-e079f893"
  }
}

variable "private_subnet_1" {}

variable "keypair" {}
