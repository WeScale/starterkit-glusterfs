output "gluster_nodes_sg" {
  value = "${aws_security_group.gluster_member.id}"
}