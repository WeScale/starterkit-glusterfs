#!/usr/bin/env bash

set -e

terraform output -state=$1 | sed -e 's/\(.*\) = \(.*\)$/\1 = "\2"/'