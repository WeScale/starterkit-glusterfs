# Coming from "network" outputs
variable "vpc_id" {}

variable "bastion_realm_security_group" {}

variable "ami_id" {}

variable "gluster_dns_zone_id" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "az_1" {}
variable "az_2" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}
variable "keypair" {}
variable "private_subnet_1" {}
variable "private_subnet_2" {}
variable "ec2_flavor" {}
