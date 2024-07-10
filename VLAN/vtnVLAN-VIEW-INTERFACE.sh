#!/bin/bash

for ARCHIVO in VLAN_INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#VLAN INTERFACE")" = "#VLAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "")
        fi
done

VLAN_NAME=$(cat VLAN/OUTPUT)
VLAN_NUMBER=$(cat $ARCHIVO | grep "#VLAN NUMBER" | awk '{print $3}')
INTERFACE=$(cat $ARCHIVO | grep "#INTERFACE" | awk '{print $2}')
ADDRESS=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
NETWORK=$(cat $ARCHIVO | grep "network" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
NETMASK=$(cat $ARCHIVO | grep "netmask" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
BROADCAST=$(cat $ARCHIVO | grep "broadcast" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

OUTPUT=$(dialog --title "Interface ${INTERFACE}" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Cancel" \
        --mixedform "VLAN information" 0 0 0 \
        "VLAN name:" 1 1 "${VLAN_NAME}" 1 23 30 0 2 \
        "VLAN number:" 2 1 "${VLAN_NUMBER}" 2 23 30 0 2 \
        "Address:" 3 1 "${ADDRESS}" 3 23 30 0 2 \
        "Network:" 4 1 "${NETWORK}" 4 23 30 0 2 \
        "Netmask:" 5 1 "${NETMASK}" 5 23 30 0 2 \
        "Broadcast:" 6 1 "${BROADCAST}" 6 23 30 0 2)

bash LAN/vtnLAN-VIEW-PROFILES.sh