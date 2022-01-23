#!/bin/bash

# proxvm
# Output in specifed format (default csv) all virtual machines on proxmox 4+
SERVER=alchemy1
USERNAME=root@pam
PASSWORD=RedRabbitSheHire6

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
    -p)
    PASSWORD=$2
    shift
    ;;
    -u)
    USERNAME=$2
    shift
    ;;
    -h)
    SERVER=$2
    shift
    ;;
    -f)
    FORMAT=$2
    shift
    ;;
    -h|--help|-?)
    echo "Usage:"
    echo "$0 [options]"
    echo " -h <server>   Server to connect to, default $SERVER"
    echo " -u <username> Username, default $USERNAME"
    echo " -p <password> Password, default $PASSWORD"
    echo " -f <format>   Output format (csv, json), default $FORMAT"
    exit 0
    ;;
    *)
    # unknown option
    echo "Error: unknown option $1"
    exit 1
    ;;
    esac
    shift # past argument or value
done

#echo Connecting to $SERVER:8006 as $USERNAME:$PASSWORD
RESPONSE=$(curl -s -k -d "username=$USERNAME&password=$PASSWORD" https://$SERVER:8006/api2/json/access/ticket)
TOKEN=$(echo $RESPONSE | jq -r .data.ticket)
CSRF_PRESERVATION_TOKEN=$(echo $RESPONSE | jq -r .data.CSRFPreventionToken)
NODES=$(curl -s -k https://$SERVER:8006/api2/json/nodes -b "PVEAuthCookie=$TOKEN" | jq -r .data[].node)

echo "---" > generatedHostsFile
for NODE in $(echo $NODES); do
    echo "[$NODE]" >> generatedHostsFile
    curl -s -k https://$SERVER:8006/api2/json/nodes/$NODE/lxc -b "PVEAuthCookie=$TOKEN" > /tmp/proxvm-lxc.json
    curl -s -k https://$SERVER:8006/api2/json/nodes/$NODE/qemu -b "PVEAuthCookie=$TOKEN" > /tmp/proxvm-qemu.json

    for VMID in $(cat /tmp/proxvm-lxc.json | jq -r .data[].vmid); do
      curl -s -k https://$SERVER:8006/api2/json/nodes/$NODE/lxc/$VMID/config -b "PVEAuthCookie=$TOKEN" > /tmp/proxvm-$VMID.json

      JSON=$(cat /tmp/proxvm-lxc.json | jq -r ".data[] | select(.vmid | tonumber | contains($VMID))")
      NAME=$(echo $JSON | jq -r .name)
      curl -s -k -b "PVEAuthCookie=$TOKEN" -H "CSRFPreventionToken: $CSRF_PRESERVATION_TOKEN" https://$SERVER:8006/api2/json/nodes/$NODE/qemu/$VMID/agent -d "command=network-get-interfaces" > /tmp/proxvm-agent-$VMID.json
      NET=$(cat /tmp/proxvm-$VMID.json | jq -r .data.net0)
      MAC=$(echo $NET | sed -re "s/[a-zA-Z0-9]+=([a-zA-Z0-9:]+),.*/\1/g")
      counter=0
      IP=""
      for ENTRY in $(cat /tmp/proxvm-agent-$VMID.json | jq -r '.data.result[]."hardware-address"'); do
        if [ "$ENTRY" != "00:00:00:00:00:00" ]; then
          MAC=$ENTRY
          IP=$(cat /tmp/proxvm-agent-$VMID.json | jq '.data.result['$counter]'."ip-addresses"[0]."ip-address"')
        fi
        counter=$((counter+1))
      done
      echo "$NAME VMID=$VMID MAC=\"$MAC\" IP=$IP" >> generatedHostsFile
      MAC=""
    done

    for VMID in $(cat /tmp/proxvm-qemu.json | jq -r .data[].vmid); do
      curl -s -k https://$SERVER:8006/api2/json/nodes/$NODE/qemu/$VMID/config -b "PVEAuthCookie=$TOKEN" > /tmp/proxvm-$VMID.json
      JSON=$(cat /tmp/proxvm-qemu.json | jq -r ".data[] | select(.vmid | tonumber | contains($VMID))") 
      NAME=$(echo $JSON | jq -r .name)
      NET=$(cat /tmp/proxvm-$VMID.json | jq -r .data.net0)
      MAC=$(echo $NET | sed -re "s/[a-zA-Z0-9]+=([a-zA-Z0-9:]+),.*/\1/g")
      #IP='arp -a | grep $HWADDR | sed -re "s/.*\(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/g"'
      curl -s -k -b "PVEAuthCookie=$TOKEN" -H "CSRFPreventionToken: $CSRF_PRESERVATION_TOKEN" https://$SERVER:8006/api2/json/nodes/$NODE/qemu/$VMID/agent -d "command=network-get-interfaces" > /tmp/proxvm-agent-$VMID.json 
      counter=0
      IP=""
      for ENTRY in $(cat /tmp/proxvm-agent-$VMID.json | jq -r '.data.result[]."hardware-address"'); do
	if [ "$ENTRY" != "00:00:00:00:00:00" ]; then
          MAC=$ENTRY
	  IP='IP='$(cat /tmp/proxvm-agent-$VMID.json | jq '.data.result['$counter]'."ip-addresses"[0]."ip-address"')
        fi
        counter=$((counter+1))
      done
      echo "$NAME VMID=$VMID MAC=\"$MAC\" $IP" >> generatedHostsFile
      MAC=""
    done
    echo "#-------------------------------------------------" >> generatedHostsFile
done

rm /tmp/proxvm-*.json

