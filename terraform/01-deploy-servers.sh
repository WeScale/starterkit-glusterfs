#!/usr/bin/env bash

terraform get -update servers

terraform plan \
    -var-file=nogit-network.tfvars \
    -var-file=packer-gluster.output.tfvars \
    -var-file=./servers/terraform.tfvars \
    -state=./servers/terraform.tfstate ./servers

terraform apply \
    -var-file=nogit-network.tfvars \
    -var-file=packer-gluster.output.tfvars \
    -var-file=./servers/terraform.tfvars \
    -state=./servers/terraform.tfstate ./servers
