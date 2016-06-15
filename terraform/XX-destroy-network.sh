#!/usr/bin/env bash

terraform get -update network

terraform destroy -force -var-file=./network/terraform.tfvars -state=./network/terraform.tfstate ./network
