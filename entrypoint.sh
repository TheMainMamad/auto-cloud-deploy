#!/bin/bash

if [ "$1" == "clear" ]; then
    rm -rf "$(pwd)/infra/ansible/vars"
    rm -rf "$(pwd)/infra/terraform/.terraform"
    rm "$(pwd)/infra/terraform/.terraform.lock.hcl"
else
    if [ ! -f ".env" ]; then
        echo "Please create a .env file based on .env.sample and fill in the required variables."
        exit 1
    fi
    chmod +x ./scripts/deploy.sh
    source .env
    ./scripts/deploy.sh
fi
