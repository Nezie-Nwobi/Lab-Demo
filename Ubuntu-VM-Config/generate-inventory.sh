#!/bin/bash

# Create the inventory file
echo "[servers]"

# Use Terraform output directly to get the list of public IP addresses
terraform output -json public_ip_addresses | jq -r '.[]' | while read ip; do
  echo "server$((++i)) ansible_host=$ip ansible_user=Nezie ansible_ssh_private_key_file=/home/Nezie/Ansible/VMSSHprivatekey_openSSH"
  done

