#!/bin/bash

INTERFACE=$(dialog \
    --stdout \
    --ok-label "Select" \
    --cancel-label "Back" \
    --title "Network Interfaces" \
    --menu "Select a network interfaces" 0 0 3 \
    1 "VLAN 40" \
    2 "VLAN 50" \
    3 "VLAN 60")

if [ $? -eq 0 ]; then
    bash DHCP/vtnDHCP-DYNAMIC-SETUP.sh
else
    bash DHCP/vtnDHCP-MENU.sh
fi
