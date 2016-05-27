#!/usr/bin/env bash

terraform get -update network

terraform apply -var-file=./network/terraform.tfvars -state=./network/terraform.tfstate ./network

terraform output -state=./network/terraform.tfstate | sed -e 's/\(.*\) = \(.*\)$/\1 = "\2"/' > nogit-network.tfvars