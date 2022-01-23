#!/bin/bash
# Generate (pseudo) random MAC addresses

RANGE=255
# Set some vendors, for prepending. Makes a MAC 'valid'
# Pick another vendor from here:
# https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf
VENDOR1='68:5d:43' # Intel
VENDOR2='00:17:A5' # Ralink
# [...]
rangen() {
        NUM=$RANDOM
        let "NUM %= $RANGE"
        OCT=$(echo "obase=16;$NUM" | bc)
        # Single (low) values prepended with '0'
        if [ ${#OCT} == 1 ]; then
            OCT='0'$OCT
        fi
        echo $OCT
}

generateRandomIntelVendorMAC(){
  A=$(rangen); B=$(rangen); C=$(rangen); D=$(rangen); E=$(rangen); F=$(rangen)
  echo "${VENDOR1}:${A}:${B}:${C}"
}

generatePurelyRandomMACAddress(){
  A=$(rangen); B=$(rangen); C=$(rangen); D=$(rangen); E=$(rangen); F=$(rangen)
  echo "${A}:${B}:${C}:${D}:${E}:${F}"
}

generateRandomRalinkVendorMACAddress(){
  A=$(rangen); B=$(rangen); C=$(rangen); D=$(rangen); E=$(rangen); F=$(rangen)
  echo "${VENDOR2}:${D}:${E}:${F}"
}
