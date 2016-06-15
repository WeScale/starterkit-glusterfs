#!/usr/bin/env bash

terraform get -update servers

terraform destroy -force \
    -var-file=nogit-network.tfvars \
    -var-file=packer-gluster.output.tfvars \
    -var-file=./servers/terraform.tfvars \
    -state=./servers/terraform.tfstate ./servers
