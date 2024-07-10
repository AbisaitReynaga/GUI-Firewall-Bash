

for ARCHIVO in VLAN_INTERFACES/*; do
    if [ "$(cat "$ARCHIVO" | grep "#PROFILE" | sed 's/#PROFILE //')" = "$(cat VLAN/OUTPUT)" ]; then
        break
    fi
done

PROFILE=$(cat VLAN/OUTPUT)
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
    --mixedform  "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "${PROFILE}" 1 23 30 0 2\
        "Address: " 2 1 "${ADDRESS}" 2 23 30 0 2\
        "Network: " 3 1 "${NETWORK}" 3 23 30 0 2\
        "Netmask: " 4 1 "${NETMASK}" 4 23 30 0 2\
        "Broadcast: " 5 1 "${BROADCAST}" 5 23 30 0 2)

bash LAN/vtnLAN-VIEW-PROFILES.sh