# Coming from "network" outputs
variable "vpc_id" {}

variable "bastion_realm_security_group" {}

variable "ami_id" {}

variable "gluster_dns_zone_id" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}
variable "keypair" {}
variable "subnet_1" {}
variable "subnet_2" {}
variable "ec2_flavor" {}
