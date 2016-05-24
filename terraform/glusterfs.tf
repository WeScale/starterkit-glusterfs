provider aws {}

variable "vpc_id" {}
variable "ami_id" {}
variable "gluster_dns_zone_id" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "min_size" {
  default = 2
}
variable "max_size" {
  default = 2
}
variable "desired_size" {
  default = 2
}
variable "keypair_name" {}
variable "subnet_1" {}
variable "subnet_2" {}
variable "ec2_flavor" {}
variable "bastion_realm_security_group" {}

resource "aws_iam_role" "node" {
  name = "gluster.node.role_assume"

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

resource "aws_iam_role_policy" "node" {

  name = "gluster.node.role_policy"

  role = "${aws_iam_role.node.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*",
        "route53:ListHostedZones"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource":"arn:aws:route53:::hostedzone/${var.gluster_dns_zone_id}"
    },
    {
      "Effect":"Allow",
      "Action":["route53:GetChange"],
      "Resource":"arn:aws:route53:::change/*"
    }
  ]
}
EOF
}

resource "aws_launch_configuration" "node" {

  name_prefix = "gluster.node"
  image_id = "${var.ami_id}"
  instance_type = "${var.ec2_flavor}"

  iam_instance_profile = "${aws_iam_instance_profile.node.id}"
  key_name = "${var.keypair_name}"

  security_groups = [
    "${var.bastion_realm_security_group}",
    "${aws_security_group.net_access.id}",
    "${aws_security_group.gluster_communication.id}",
    "${aws_security_group.gluster_member.id}"
  ]
  ebs_optimized = false
  user_data = <<EOF

#cloud-config
runcmd:
  - [ /bin/bash, /opt/boot.sh ]
write_files:
  - content: |
        ---
        instance:
          parent_dns_zone: "${var.gluster_dns_zone_id}"
    path: /opt/boot-data.yml

EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "net_access" {
  name = "net_access"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gluster_member" {
  name = "gluster_member"
  vpc_id = "${var.vpc_id}"
}
resource "aws_security_group" "gluster_communication" {
  name = "gluster_communication"
  vpc_id = "${var.vpc_id}"

  ingress{
    from_port = 24007
    to_port = 24008
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }

  egress{
    from_port = 24007
    to_port = 24008
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }

  ingress{
    from_port = 49152
    to_port = 49352
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }

  egress{
    from_port = 49152
    to_port = 49352
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }

  ingress{
    from_port = 111
    to_port = 111
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }
  egress{
    from_port = 111
    to_port = 111
    protocol = "TCP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }
  ingress{
    from_port = 111
    to_port = 111
    protocol = "UDP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }
  egress{
    from_port = 111
    to_port = 111
    protocol = "UDP"
    security_groups = ["${aws_security_group.gluster_member.id}"]
  }
}

resource "aws_autoscaling_group" "node" {

  availability_zones = ["${var.aws_region}a", "${var.aws_region}c"]

  name = "asg.gluster.nodes"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_size}"

  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true

  vpc_zone_identifier = ["${var.subnet_1}", "${var.subnet_2}"]

  launch_configuration = "${aws_launch_configuration.node.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "glusterfs-node"
    propagate_at_launch = true
  }
}

resource "aws_iam_instance_profile" "node" {
  name = "glusterfs.ec2"
  roles = ["${aws_iam_role.node.name}"]
}
