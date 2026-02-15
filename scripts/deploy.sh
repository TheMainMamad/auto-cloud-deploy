#!/bin/bash

SUPPORTED_APPS=(
    "custom"
    "jenkins"
    "marzban"
    "mattermost"
    "minio"
    "redis"
)

ROOT_PATH=$(dirname "$(pwd)")

function help_message {
    echo  "__   _  _  ____  __         ___  __     __   _  _  ____      ____  ____  ____  __     __  _  _  "
    echo "/ _\ / )( \(_  _)/  \  ___  / __)(  )   /  \ / )( \(    \ ___(    \(  __)(  _ \(  )   /  \( \/ ) "
    echo "/    \) \/ (  )( (  O )(___)( (__ / (_/\(  O )) \/ ( ) D ((___)) D ( ) _)  ) __// (_/\(  O ))  / "
    echo "\_/\_/\____/ (__) \__/       \___)\____/ \__/ \____/(____/    (____/(____)(__)  \____/ \__/(__/  "
    echo ""
    echo "Version: v1.0-beta"
    echo "Repository: https://github.com/TheMainMamad/auto-cloud-deploy.git"
    echo "Clouds: [arvancloud]"
    echo "Supported Dockerized Apps: ${SUPPORTED_APPS[@]}"
    echo "IaC: Terraform, Ansible"
    echo "Root PATH: $ROOT_PATH"
    echo ""
    echo ""
}

function set_variable {
    echo "$1: $2" >> $ROOT_PATH/infra/ansible/vars/main.yml
}

function select_deployments {
    read -p "Enter required apps to install: " selected_app
    set_variable "app_name" $selected_app
    case "$selected_app" in
        jenkins)
            echo "No required variable"
        ;;
        redis)
            echo "Auto generate redis credentials"
            set_variable "redis_password" "$(xxd -l 16 -p /dev/urandom | tr -d '\n')"
        ;;
        marzban)
            echo "No required variable"
        ;;
        minio)
            echo "Auto generate minio credentials"
            set_variable "minio_username" "root_$(xxd -l 16 -p /dev/urandom | tr -d '\n')"
            set_variable "minio_password" "$(xxd -l 16 -p /dev/urandom | tr -d '\n')"
        ;;
        mattermost)
            echo "Auto generate Mattermost credentials"
            set_variable "psql_user" "postgres_$(xxd -l 16 -p /dev/urandom | tr -d '\n')"
            set_variable "psql_password" "$(xxd -l 16 -p /dev/urandom | tr -d '\n')"
            set_variable "psql_db" "mattermost"
        ;;
        custom)
            read -p "Please enter your custom app name: " app_name
            read -p "Please enter your custom app image: " app_image
            read -p "Please enter your custom app tag: (default:latest)" app_tag
            [ -z "$app_tag" ] && app_tag="latest"
            read -p "Please enter your custom app ports: (default:8000)" app_ports
            [ -z "$app_ports" ] && app_ports="8000"
            read -p "Please enter your custom app volumes: (default:none)" app_volumes
            [ -n "$app_volumes" ] && set_variable "app_volumes" "$app_volumes"
            read -p "Please enter your custom app command: (default:none)" app_command
            [ -n "$app_command" ] && set_variable "app_command" "$app_command"
            set_variable "app_name" "$app_name"
            set_variable "app_image" "$app_image"
            set_variable "app_tag" "$app_tag"
            set_variable "app_ports" "$app_ports"
        ;;
        *)
            echo "[-] Unsupported app entered"
        ;;
    esac
}

function create_inventory_file {
    cat > "${ROOT_PATH}/infra/ansible/inventory.yml" <<EOF
all:
  hosts:
    abrak:
      ansible_host: $1
      ansible_user: ubuntu
EOF
}

function terraform_run {
    export TF_VAR_api_key="$CLOUD_API_KEY"
    export TF_VAR_abrak_name="$SERVER_NAME"
    export TF_VAR_region="$REGION"
    export TF_VAR_disk_size="$DISK_SIZE"

    cd ${ROOT_PATH}/infra/terraform
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    IP=$(terraform output -raw abrak_ip || { echo "[!] Failed to get IP"; exit 1; })
    echo "Server IP: $IP"
    create_inventory_file $IP
    cd ${ROOT_PATH}
}

function ansible_run {
    cd ${ROOT_PATH}/infra/ansible
    ansible-playbook -i inventory.yml playbook.yml
}

function main {
    set -e
    help_message
    select_deployments
    terraform_run
    ansible_run
}

main