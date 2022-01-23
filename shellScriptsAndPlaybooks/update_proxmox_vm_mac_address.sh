source "generate_random_mac.sh"
#!/bin/sh

updateProxmoxVMMacAddress(){
  if [ "$#" -gt 2 ] || [ "$#" -lt 1 ]; then
    echo "ERROR!"
    echo "Function accepts one or two params. Call function like that:"
    echo "./update_proxmox_vm_mac_address.sh 2003 AA:BB:CC:DD:EE:FF      # 2003 is the VMID ot the Proxmox VM you want to update AA:BB:CC:DD:EE:FF is the desired MAC"
    echo "./update_proxmox_vm_mac_address.sh 2003                        # Second param is NOT passed, so random MAC will be generated for that VM!"
    exit 1
  fi

  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]]; then
    echo "Error: First param passed is NOT a number! Call function like that:"
    echo "./update_proxmox_vm_mac_address.sh 2003 AA:BB:CC:DD:EE:FF      # 2003 is the VMID ot the Proxmox VM you want to update AA:BB:CC:DD:EE:FF is the desired MAC"
    echo "./update_proxmox_vm_mac_address.sh 2003                        # Second param is NOT passed, so random MAC will be generated for that VM!"
    exit 1
  fi

  re='^[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}$'
  if [[ "$#" -eq 2 ]] && ! [[ $2 =~ $re ]]; then
    echo "Error: Second param passed is NOT a valid MAC address! Call function like that:"
    echo "./update_proxmox_vm_mac_address.sh 2003 AA:BB:CC:DD:EE:FF      # 2003 is the VMID ot the Proxmox VM you want to update AA:BB:CC:DD:EE:FF is the desired MAC"
    echo "./update_proxmox_vm_mac_address.sh 2003                        # Second param is NOT passed, so random MAC will be generated for that VM!"
    exit 1
  fi

  a="ansible-playbook update_vm_mac_address.yml --vault-password-file .././vault_pass.py -v --extra-vars \""
  b="vmid="
  c="macaddress="

  if [ "$#" -eq 1 ]; then
    MAC=$(generateRandomIntelVendorMAC)
  else
    MAC=$2	  
  fi

  echo "$a$b$1 $c$MAC\""
  eval "$a$b$1 $c$MAC\""
}
