#!/bin/bash

SUPPORTED_APPS=(
    "custom"
    "jenkins"
    "marzban"
    "mattermost"
    "minio"
    "redis"
)

ROOT_PATH="$(pwd)"
VARS_DIR="$ROOT_PATH/infra/ansible/vars"
VARS_FILE="$VARS_DIR/main.yml"

if ! [ -f "$VARS_FILE/main.yml" ]; then
    mkdir $VARS_DIR && touch $VARS_FILE/main.yml
fi

function help_message {
    echo "   __   _  _  ____  __         ___  __     __   _  _  ____      ____  ____  ____  __     __  _  _  "
    echo "  / _\ / )( \(_  _)/  \  ___  / __)(  )   /  \ / )( \(    \ ___(    \(  __)(  _ \(  )   /  \( \/ ) "
    echo " /    \) \/ (  )( (  O )(___)( (__ / (_/\(  O )) \/ ( ) D ((___)) D ( ) _)  ) __// (_/\(  O ))  / "
    echo " \_/\_/\____/ (__) \__/       \___)\____/ \__/ \____/(____/    (____/(____)(__)  \____/ \__/(__/  "
    echo ""
    echo "Version: v1.0-beta"
    echo "Repository: https://github.com/TheMainMamad/auto-cloud-deploy.git"
    echo "Clouds: [Arvancloud, Local(virtualbox)]"
    echo "Supported Dockerized Apps: ${SUPPORTED_APPS[@]}"
    echo "IaC: Terraform, Ansible"
    echo "Root PATH: $ROOT_PATH"
    echo "Ansible Vars file: $VARS_FILE"
    echo ""
    printf "\033[1;33m[!][!] Before running script make sure you filled .env file correctly. If not exist copy from .env.sample [!][!]\033[0m\n"
}

function set_variable {
    echo "$1: $2" >> $VARS_FILE
}

function set_list_variable {
    echo -e "$1:" >> $VARS_FILE
    for app in $2; do
        echo -e "  - ${app}" >> $VARS_FILE
    done
    echo -e "\n"
}

function select_deployments {
    read -p "Enter required apps to install: " selected_apps
    set_list_variable "apps" "${selected_apps}"
    for selected_app in ${selected_apps[@]}; do
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
    done
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

function select_cloud {
    echo "Select cloud provider:"
    echo "1) Arvancloud"
    echo "2) Virtualbox (Local)"
    read -p "Enter the number corresponding to your choice: " cloud_choice
    case "$cloud_choice" in
        1)
            export CLOUD_PROVIDER="arvancloud"
        ;;
        2)
            export CLOUD_PROVIDER="virtualbox"
        ;;
        *)
            echo "[-] Invalid choice. Please select a valid cloud provider."
            exit 1
        ;;
    esac
}

function get_arvan_ip {
    export IP_ADDRESS=$(curl -4 -sS -H "Authorization: Apikey $1" \
    "https://napi.arvancloud.ir/ecc/v1/regions/$2/servers/$3" \
    | jq -r '.data.addresses
            | to_entries
            | .[].value[]
            | select(.version=="4" and .is_public==true)
            | .addr
            ' | head -n1
    )
    echo $IP_ADDRESS
}

function resolve_vagrant_box_url() {
  local api="https://app.vagrantup.com/api/v2/box/$1"

  local url
  url="$(curl -fsSL "$api" | jq -r '.current_version.providers[] | select(.name=="virtualbox") | .download_url' | head -n1)"
  if [ -z "$url" ] || [ "$url" = "null" ]; then
    echo "[!] No virtualbox provider found for box: $1" >&2
    return 1
  fi

  return "$url"
}

function terraform_run {
    source ${ROOT_PATH}/.env

    cd ${ROOT_PATH}/infra/terraform/environment/${CLOUD_PROVIDER}
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan

    INSTANCE_ID=$(terraform output -raw instance_id)
    REGION=$(terraform output -raw region)
    USER=$(terraform output -raw instance_username)

    export IP="$(get_arvan_ip "$CLOUD_API_KEY" "$REGION" "$INSTANCE_ID")"

    echo "Server IP: $IP"
    create_inventory_file $IP
    cd ${ROOT_PATH}
}

function ansible_run {
    echo "Add key host to known file ..."
    ssh-keygen -R $IP
    ssh-keyscan -H $IP >> ~/.ssh/known_hosts
    cd ${ROOT_PATH}/infra/ansible
    ansible-playbook -i inventory.yml playbook.yml
}

function main {
    set -e
    help_message
    select_deployments
    select_cloud
    terraform_run
    ansible_run
}

main
