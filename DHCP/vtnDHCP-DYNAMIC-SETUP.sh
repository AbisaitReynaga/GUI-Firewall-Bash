#!/bin/bash

OUTPUT=$(dialog  --title "Interface selected Eth0" \
        --colors \
        --stdout \
        --help-button \
        --ok-label "Apply" \
        --cancel-label "Cancel" \
        --form "Edit the conection" 0 0 0 \
        "Profile name: " 1 1 "" 1 23 30 0 \
        "Network: " 2 1 "" 2 23 30 0  \
        "Range start: " 3 1 "" 3 23 30 0 \
        "Range end: " 4 1 "" 4 23 30 0 \
        "Gateway: " 5 1 "" 5 23 30 0  \
        "Netmask: " 6 1 "" 6 23 30 0 \
        "Broadcast: " 7 1 "" 7 23 30 0 \
        "DNS server: " 8 1 "" 8 23 30 0  \
        "Alternate DNS server: " 9 1 "" 9 23 30 0)

if [ $? -eq 0 ]; then
    echo "Apply"
else
    bash DHCP/vtnDHCP-INTERFACES.sh
fi