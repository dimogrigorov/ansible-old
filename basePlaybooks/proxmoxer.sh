#!/bin/sh

while :
do
  echo "Please enter vmid on alchemy2 to start VM: "
  read input_variable

  re='^[0-9]+$'
  if ! [[ $input_variable =~ $re ]]; then
    echo "Error: Param passed is NOT a number! Please enter a valid one:"
  else
    break
  fi
done

ansible-playbook proxmoxer.yml --extra-vars "vmid=$input_variable"
