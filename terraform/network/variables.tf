variable "aws_region" {
  default = "eu-west-1"
}


variable "vpc_name" {
  default = "LAB"
}
variable "vpc_cidr" {}

variable "amis" {
  description = "AMIs by region"
  default = {
    eu-west-1 = "ami-e079f893" # Debian 8.4
  }
}



variable "public_subnet_cidr_a" {}
variable "public_subnet_cidr_c" {}

variable "private_subnet_cidr_a" {}
variable "private_subnet_cidr_c" {}

variable "aws_key_path" {}
variable "aws_key_name" {}
