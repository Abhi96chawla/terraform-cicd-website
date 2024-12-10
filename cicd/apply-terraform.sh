#!/bin/bash

# Exit script if any command fails
set -eu

cd ..

terraform init

terraform apply -auto-approve