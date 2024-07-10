#!/bin/bash
INTERFACE=$(cat LAN/OUTPUT | grep "#INTERFACE" | awk '{print $2}')
OUTPUT=$(dialog  --title "Interface selected ${INTERFACE}" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Cancel" \
        --form "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0 \
        "Address: " 2 1 "${ADDRESS}" 2 23 30 0  \
        "Network: " 3 1 "${NETWORK}" 3 23 30 0  \
        "Netmask: " 4 1 "${NETMASK}" 4 23 30 0  \
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
network ${NETWORK}
netmask ${NETMASK}
broadcast  ${BROADCAST}" > INTERFACES/${INTERFACE}





if [ $? -eq 0 ]; then
    echo "Apply selected"
else
    bash LAN/vtnLAN-MENU.sh
fi
