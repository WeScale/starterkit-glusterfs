#!/usr/bin/env bash

BUILDMARK="$(date "+%Y%m%d-%H%M")"

packer build \
    -var-file packer_aws_workspace.json \
    -var ami_role=gluster \
    -var buildmark=$BUILDMARK \
    packer-build-ami.json

AMI_ID=$(aws ec2 describe-images --filter "Name=name,Values=ami-gluster-$BUILDMARK" | jq '.Images[].ImageId' -r)

echo "gluster_ami_id = \"$AMI_ID\"" > ../terraform/packer-gluster.output.tfvars
