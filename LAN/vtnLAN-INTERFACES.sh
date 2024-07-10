#!/bin/bash

INTERFACE=$(dialog \
    --stdout \
    --ok-label "Select" \
    --cancel-label "Back" \
    --title "Network Interfaces" \
    --menu "Select a network interfaces" 0 0 3 \
    1 "Eth0" \
    2 "Eth1" \
    3 "Eth2")

if [ $? -eq 0 ]; then
    bash LAN/vtnLAN-SETUP.sh
else
    bash LAN/vtnLAN-PROFILES.sh
fi