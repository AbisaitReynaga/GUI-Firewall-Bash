#!/bin/bash

INTERFACE=$(cat WAN/OUTPUT | grep "#INTERFACE" | awk '{print $2}')


OUTPUT=$(dialog  --title "Network Interface: ${INTERFACE}" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Back" \
        --form "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0   \
        "Address: " 2 1 "${ADDRESS}" 2 23 30 0  \
        "Gateway: " 3 1 "${GATEWAY}" 3 23 30 0  \
        "Netmask: " 4 1 "${NETMASK}" 4 23 30 0  \
        "DNS server: " 5 1 "${DNS}" 5 23 30 0  \
        "Alternate DNS server: " 6 1 "${DNS1}" 6 23 30 0)

PROFILE=$(echo "$OUTPUT" | sed -n 1p)
ADDRESS=$(echo "$OUTPUT" | sed -n 2p)
GATEWAY=$(echo "$OUTPUT" | sed -n 4p)
NETMASK=$(echo "$OUTPUT" | sed -n 3p)
DNS=$(echo "$OUTPUT" | sed -n 5p)
DNS1=$(echo "$OUTPUT" | sed -n 6p)

echo -e "#WAN INTERFACE
#INTERFACE ${INTERFACE}
#PROFILE ${PROFILE}
address ${ADDRESS}
gateway ${GATEWAY}
netmask ${NETMASK}
dns1     ${DNS}
dns2 ${DNS1}" > INTERFACES/${INTERFACE}


if [ $? -eq 0 ]; then
    bash WAN/vtnWAN-PROFILES.sh
else
    bash WAN/vtnWAN-INTERFACES.sh
fi

