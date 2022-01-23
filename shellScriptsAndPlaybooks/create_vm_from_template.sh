#!/bin/sh

echo "ansible-playbook create_vm_from_template.yml --extra-vars 'new_machine_name=$1 new_vmid=$2 template_name=$3'"
ansible-playbook create_vm_from_template.yml --extra-vars "new_machine_name=$1 vmid=$2 template_name=$3" --vault-password-file .././vault_pass.py
