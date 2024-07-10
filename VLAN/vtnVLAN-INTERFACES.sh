#!/bin/bash
LAN_COUNTER=0
INTERFACES_NAMES=()

# Function to count LAN interfaces
function LAN_COUNTER_INTERFACES()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat "$ARCHIVO" | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            LAN_COUNTER=$((LAN_COUNTER + 1))
        fi
    done
}

function GET_INTERFACES_NAMES()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            INTERFACES_NAMES+=("$(cat $ARCHIVO | grep "#INTERFACE" | sed 's/#INTERFACE //')" "$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')")
            
        fi
    done
}

GET_INTERFACES_NAMES

  OPC_SELECTED=$(dialog \
  --stdout \
  --ok-label "Select" \
  --cancel-label "Back" \
  --title "Network Interfaces" \
  --menu "Select a LAN network interface" 0 0 "${#INTERFACES_NAMES[@]}" \
     "${INTERFACES_NAMES[@]}")


if [ $? -eq 0 ]; then
    echo "#INTERFACE ${OPC_SELECTED}" > VLAN/OUTPUT
    bash VLAN/vtnVLAN-SETUP.sh
else
    bash LAN/vtnLAN-MENU.sh
fi


