#!/bin/bash

##UserID
userID=Extern
#vmidRange=2200-2220


##Deploy DHCP from template ID 2019##
dhcpTemplateVmid=2199
newDhcpVmid=2001

ansible-playbook create_vm_from_template.yml --extra-vars "new_machine_name=DHCP-Server$userID vmid=$dhcpTemplateVmid newid=$newDhcpVmid template_name=dhcp-template-ansible" --vault-password-file .././vault_pass.py

##Start the DHCP-Server
ansible-playbook start_vm.yml --extra-vars "vmid=$newDhcpVmid" --vault-password-file .././vault_pass.py

##Deploy one machine from the centos template
centosTemplateVmid=2000
newCentosVmid=2200

ansible-playbook create_vm_from_template.yml --extra-vars "new_machine_name=centosVM$userID vmid=$centosTemplateVmid newid=$newCentosVmid template_name=centos-template" --vault-password-file .././vault_pass.py

##Retrieve MAC and Update DHCP Server
ipaddress=192.168.1.2
dhcpHostIp=10.5.200.55

output=$(ansible-playbook pvesh.yml --extra-vars vmid=$newCentosVmid)
re='[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*'
mac=$(grep -m 1 -o $re <<< $output | head -1 )
echo $mac
a="ansible-playbook insert_new_entry_in_dhcp.yml -v --vault-password-file .././vault_pass.py --extra-vars \""
b="ipaddress="
c="macaddress="
d="uniqueDhcpName="
e="dhcpHostIp="
echo  "$a$b$ipaddress $c$mac $d$newCentosVmid$userID $e$dhcpHostIp\""
eval "$a$b$ipaddress $c$mac $d$newCentosVmid$userID $e$dhcpHostIp\""

##Start the vm
ansible-playbook start_vm.yml --extra-vars "vmid=$newCentosVmid" --vault-password-file .././vault_pass.py
