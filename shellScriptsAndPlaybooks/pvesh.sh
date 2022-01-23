#!/bin/sh

source "insert_new_dhcp_entry.sh"
while :
do
  echo "Please enter vmid to get mac: "
  read input_variable

  re='^[0-9]+$'
  if ! [[ $input_variable =~ $re ]]; then
    echo "Error: Param passed is NOT a number! Please enter a valid one:"
  else
    break
  fi
done

output=$(ansible-playbook pvesh.yml --extra-vars vmid=$input_variable)
re='[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*:[0-9A-Z]*'
mac=$(grep -m 1 -o $re <<< $output)

