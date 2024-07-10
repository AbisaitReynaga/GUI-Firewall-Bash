#!/bin/bash

for ARCHIVO in INTERFACES/*; do
    if [ "$(cat "$ARCHIVO" | grep "#PROFILE" | sed 's/#PROFILE //')" = "$(cat LAN/OUTPUT)" ]; then
        break
    fi
done

PROFILE=$(cat LAN/OUTPUT)
INTERFACE=$(cat $ARCHIVO | grep "#INTERFACE" | awk '{print $2}')
ADDRESS=$(cat $ARCHIVO | grep "address" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
NETWORK=$(cat $ARCHIVO | grep "network" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
NETMASK=$(cat $ARCHIVO | grep "netmask" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
BROADCAST=$(cat $ARCHIVO | grep "broadcast" | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')


OUTPUT=$(dialog  --title "Network Interface: ${INTERFACE}" \
    --colors \
    --stdout \
    --ok-label "Apply" \
    --cancel-label "Back" \
    --form "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0 \
        "Address: " 2 1 "${ADDRESS}" 2 23 30 0 \
        "Network: " 3 1 "${NETWORK}" 3 23 30 0 \
        "Netmask: " 4 1 "${NETMASK}" 4 23 30 0 \
        "Broadcast: " 5 1 "${BROADCAST}" 5 23 30 0)

PROFILE=$(echo "$OUTPUT" | sed -n 1p)
ADDRESS=$(echo "$OUTPUT" | sed -n 2p)
NETWORK=$(echo "$OUTPUT" | sed -n 3p)
NETMASK=$(echo "$OUTPUT" | sed -n 4p)
BROADCAST=$(echo "$OUTPUT" | sed -n 5p)

echo -e "#LAN INTERFACE 
#INTERFACE ${INTERFACE}
#PROFILE ${PROFILE}
address ${ADDRESS}
gateway ${GATEWAY}
netmask ${NETMASK}
broadcast ${BROADCAST}" > INTERFACES/${INTERFACE}
