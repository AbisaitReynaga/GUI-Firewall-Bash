#!/bin/bash

OUTPUT=$(cat SERVICES/DHCP/OUTPUT)

function LIST_PROFILES_LAN()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#PROFILE")" = "#PROFILE ${OUTPUT}" ]; then
            PROFILE=$OUTPUT
            INTERFACE=$(cat $ARCHIVO | grep "#INTERFACE" | awk '{print $2}')
            NETWORK=$(cat $ARCHIVO | grep "network" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            ADDRESS_START=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3}').
            ADDRESS_END=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3}').
            GATEWAY=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            NETMASK=$(cat $ARCHIVO | grep "netmask" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            BROADCAST=$(cat $ARCHIVO | grep "broadcast" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            break
        fi
    done
}
function LIST_PROFILES_VLAN()
{
    for ARCHIVO in VLAN_INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#PROFILE")" = "#PROFILE ${OUTPUT}" ]; then
            PROFILE=$OUTPUT
            INTERFACE=$(cat $ARCHIVO | grep "#INTERFACE" | awk '{print $2}')
            NETWORK=$(cat $ARCHIVO | grep "network" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            ADDRESS_START=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3}').
            ADDRESS_END=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3}').
            GATEWAY=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            NETMASK=$(cat $ARCHIVO | grep "netmask" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            BROADCAST=$(cat $ARCHIVO | grep "broadcast" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
            break
        fi
    done
}

LIST_PROFILES_LAN
LIST_PROFILES_VLAN

OUTPUT=$(dialog  --title "DHCP Configuration" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Back" \
        --mixedform "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0 2 \
        "Network: " 2 1 "${NETWORK}" 2 23 30 0 2 \
        "Netmask: " 3 1 "${NETMASK}" 3 23 30 0 2 \
        "Gateway: " 4 1 "${GATEWAY}" 4 23 30 0 2 \
        "Broadcast" 5 1 "${BROADCAST}" 5 23 30 0 2 \
        "Address Start: " 6 1 "${ADDRESS_START}" 6 23 30 0 0 \
        "Address End: " 7 1 "${ADDRESS_END}" 7 23 30 0 0 \
        "DNS server: " 8 1 "${DNS_P}" 8 23 30 0 0 \
        "Alternate DNS server: " 9 1 "${DNS_S}" 9 23 30 0 0)

if [ $? -eq 0 ]; then
PROFILE=$(echo "$OUTPUT" | sed -n 1p)
NETWORK=$(echo "$OUTPUT" | sed -n 2p)
NETMASK=$(echo "$OUTPUT" | sed -n 3p)
GATEWAY=$(echo "$OUTPUT" | sed -n 4p)
BROADCAST=$(echo "$OUTPUT" | sed -n 5p)
ADDRESS_START=$(echo "$OUTPUT" | sed -n 6p)
ADDRESS_END=$(echo "$OUTPUT" | sed -n 7p)
#LEASE_TIME=$(echo "$OUTPUT" | sed -n 7p)
DNS_P=$(echo "$OUTPUT" | sed -n 8p)
DNS_S=$(echo "$OUTPUT" | sed -n 9p)

echo -e "
shared-network "${INTERFACE}" {
    subnet ${NETWORK} netmask ${NETMASK} {
        authoritative;
        range ${ADDRESS_START} ${ADDRESS_END}; 
        option routers ${GATEWAY};
        option subnet-mask ${NETMASK};
        option broadcast-address ${BROADCAST};
        option netbios-node-type 4; # Difusión antes que Servidor WINS
        #option netbios-node-type 8; # Servidor WINS antes que difusión
        #option domain-name "lan.local";
        #option domain-name-servers ${DNS_P} ${DNS_S};
        #option netbios-name-servers 192.168.1.254;
    }
}" > DHCP_INTERFACES/OUTPUT_1
fi

