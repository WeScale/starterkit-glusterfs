#!/usr/bin/env bash

terraform apply

cat terraform.tfstate | jq '.modules[].outputs' > packer_aws_workspace.json