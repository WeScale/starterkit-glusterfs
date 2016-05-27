#!/usr/bin/env bash

SG_GLUSTER="$(terraform output -state=servers/terraform.tfstate gluster_nodes_sg)"

aws ec2 describe-instances --filter "Name=instance.group-id,Values=$SG_GLUSTER" | jq '.Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress' -r