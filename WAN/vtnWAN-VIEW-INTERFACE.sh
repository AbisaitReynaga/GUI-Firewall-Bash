#!/bin/bash

for ARCHIVO in INTERFACES/*; do
    if [ "$(cat "$ARCHIVO" | grep "#PROFILE" | sed 's/#PROFILE //')" = "$(cat WAN/OUTPUT)" ]; then
        break
    fi
done

PROFILE=$(cat WAN/OUTPUT)
INTERFACE=$(cat $ARCHIVO | grep "#INTERFACE" | awk '{print $2}')
ADDRESS=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
GATEWAY=$(cat $ARCHIVO | grep "gateway" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
NETMASK=$(cat $ARCHIVO | grep "netmask" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
DNS=$(cat $ARCHIVO | grep "dns1" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
DNS1=$(cat $ARCHIVO | grep "dns2" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

OUT=$(dialog  --title "Network Interface: ${INTERFACE}" \
        --colors \
        --stdout \
        --ok-label "OK" \
        --nocancel \
        --mixedform "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0 2\
        "Address: " 2 1 "${ADDRESS}" 2 23 30 0 2\
        "Gateway: " 3 1 "${GATEWAY}" 3 23 30 0 2\
        "Netmask: " 4 1 "${NETMASK}" 4 23 30 0 2\
        "DNS server: " 5 1 "${DNS}" 5 23 30 0 2\
        "Alternate DNS server: " 6 1 "${DNS1}" 6 23 30 0 2)

bash WAN/vtnWAN-VIEW-PROFILES.sh