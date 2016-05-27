#!/usr/bin/env bash

terraform get -update servers

terraform apply -var-file=nogit-network.tfvars -var-file=./servers/terraform.tfvars -state=./servers/terraform.tfstate ./servers
