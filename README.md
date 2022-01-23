##
## Ansible Configuration Changes
sudo_user     = root
ask_sudo_pass = True
ask_pass      = True


## System variables needed
For the vault to decrypt a systemvariable VAULT_PASSWORD with the correct password needs to be set.
* export VAULT_PASSWORD=[PW]
For the playbooks to able to execute from any folder an ANSIBLE_HOME with the correct path is needed
* export ANSIBLE_HOME=~/ansible


## Ansible Commands Used
* ansible-playbook proxmoxer.yml --vault-password-file ./vault_pass.py 
* ansible-playbook prep_host_with_proxmoxer.yml --vault-password-file
* ansible-playbook create_vm_from_template.yml --vault-password-file ./vault_pass.py
* ansible-playbook get_mac_address_from_facts.yml --vault-password-file ./vault_pass.py
* ansible-playbook start_vm_afterthat_start_service.yml --vault-password-file ./vault_pass.py
* ansible-playbook stop_service_afterthat_stop_vm.yml --vault-password-file ./vault_pass.py
* ansible-playbook insert_new_entry_in_dhcp.yml --vault-password-file ./vault_pass.py --extra-vars "macaddress='' ipaddress=''"
* ansible-playbook run_shell_on_list_vms.yml --extra-vars "script_path=/*/*/*/*/test.sh script_params=paramValue1 paramValue2" --vault-password-file .././vault_pass.py -v

currently only VM with name=elastic-node-0 is in the list of VMs that could be stopped/started.
If you want to call the playbook on more VMs (first you should talk to Kristiyan) uncomment the VM names in the corresponding
to that playbook host file under 'managed' group.

In order for start/stop playbook to work with only ONE 'configuration' file and
not to use one inventory hosts file + one config file(with VM ids / names) that is passed as a variable to the playbook
an association should be added for each managed host in /etc/hosts with: *.*.*.*(ip of the host) vm_name_taken_from_alchemy !!!
for example /etc/hosts should look like:
10.5.203.209 elastic-node-0
10.5.203.209 elastic-node-1
.....

## proxmoxer_kvm changes needed to enable Nic Mac update
To enable updating of the NIC Mac we changed lib/ansible/modules/cloud/misc/proxmox_kvm.py according to
https://github.com/ansible/ansible/pull/28442/files

