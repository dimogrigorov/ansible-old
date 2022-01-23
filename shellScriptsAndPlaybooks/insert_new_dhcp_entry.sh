#!/bin/sh
randomString(){
   cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1
}
insertNewStaticDhcpEntry() {
  if ! [ "$#" -eq 2 ]; then
    echo "ERROR!" 
    echo "Function accepts two params. Use like:" 
    echo "./insert_new_dhcp_entry.sh 10.5.0.4  AA:BB:CC:DD:EE:FF #10.5.0.4 is the example IP address and "
    echo "If second param is NOT passed random MAC will be generaddted!"
    exit 1
  fi
  re='^[0-9]+.[0-9]+.[0-9]+.[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "Error: First param passed is NOT a valid IP address! Call function like that:"
    echo "./insert_new_dhcp_entry.sh 10.5.0.4  AA:BB:CC:DD:EE:FF #10.5.0.4 is the desired IP address and AA:BB:CC:DD:EE:FF is the desired MAC address"
    exit 1
  fi

  re='^[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}:[0-9A-Z]{2}$'
  if ! [[ $2 =~ $re ]] ; then
    echo "Error: Second param passed is NOT a valid MAC address! Call function like that:"
    echo "./insert_new_dhcp_entry.sh 10.5.0.4  AA:BB:CC:DD:EE:FF #10.5.0.4 is the desired IP address and AA:BB:CC:DD:EE:FF is the desired MAC address"
    exit 1
  fi

  a="ansible-playbook insert_new_entry_in_dhcp.yml -v --vault-password-file .././vault_pass.py --extra-vars \""
  b="ipaddress="
  c="macaddress="
  d="uniqueDhcpName="
  d=$d$(randomString)
  echo  "$a$b$1 $c$2 $d\""
  #eval "$a$b$1 $c$2 $d\""
}
