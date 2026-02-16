#!/bin/bash

if [ "$1" == "clear" ]; then
    rm -rf "$(pwd)/infra/ansible/vars"
    rm -rf "$(pwd)/infra/terraform/.terraform"
    rm "$(pwd)/infra/terraform/.terraform.lock.hcl"
else
    chmod +x ./scripts/deploy.sh
    ./scripts/deploy.sh
fi