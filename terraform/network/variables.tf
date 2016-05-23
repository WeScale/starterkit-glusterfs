variable "aws_credentials_file" {}
variable "aws_credentials_profile" {}

variable "aws_region" {
  default = "eu-west-1"
}


variable "environment" {
  default = "tmplab"
}

variable "amis" {
  description = "AMIs by region"
  default = {
    eu-west-1 = "ami-e079f893" # Debian 8.4
  }
}

variable "vpc_cidr" {}

variable "public_subnet_cidr" {}
variable "public_subnet_cidr_c" {}

variable "private_subnet_cidr" {}
variable "private_subnet_cidr_c" {}

variable "aws_key_path" {}
variable "aws_key_name" {}
