INTERFACE=$(cat VLAN/OUTPUT | grep "#INTERFACE" | awk '{print $2}')

OUTPUT=$(dialog  --title "Interface ${INTERFACE}" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Cancel" \
        --form "Edit the conection" 0 0 0 \
        "VLAN name: " 1 1 "${VLAN_NAME}" 1 23 30 0   \
        "VLAN number: " 2 1 "${VLAN_NUMBER}" 2 23 30 0  \
        "Address: " 3 1 "${ADDRESS}" 3 23 30 0  \
        "Network: " 4 1 "${NETWORK}" 4 23 30 0  \
        "Netmask: " 5 1 "${NETMASK}" 5 23 30 0  \
        "Broadcast: " 6 1 "${BROADCAST}" 6 23 30 0)

if [ $? -eq 0 ]; then
VLAN_NAME=$(echo "$OUTPUT" | sed -n 1p)
VLAN_NUMBER=$(echo "$OUTPUT" | sed -n 2p)
ADDRESS=$(echo "$OUTPUT" | sed -n 3p)
NETWORK=$(echo "$OUTPUT" | sed -n 4p)
NETMASK=$(echo "$OUTPUT" | sed -n 5p)
BROADCAST=$(echo "$OUTPUT" | sed -n 6p)

echo -e "#VLAN INTERFACE
#INTERFACE ${INTERFACE}
#PROFILE ${VLAN_NAME}
#VLAN NUMBER ${VLAN_NUMBER}
#DHCP DISABLE
address ${ADDRESS}
network ${NETWORK}
netmask ${NETMASK}
broadcast  ${BROADCAST}" > VLAN_INTERFACES/vlan${VLAN_NUMBER}@${INTERFACE}
    bash VLAN/vtnVLAN-PROFILES.sh
else
    bash VLAN/vtnVLAN-INTERFACES.sh
fi