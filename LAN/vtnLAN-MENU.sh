#!/bin/bash

OPC_MENU=$(dialog --title "LAN Settings" \
        --colors \
        --stdout \
        --ok-label "Select" \
        --cancel-label "Back to menu" \
        --menu "Select an option:" 0 0 0 \
        1 "Configure LAN interface" \
        2 "View LAN interface" \
        3 "Create VLAN interface" \
        4 "View VLANs")

if [ $? -eq 0 ]; then

    case $OPC_MENU in
    1)
      bash LAN/vtnLAN-PROFILES.sh
    ;;
    2)
      echo ""
    ;;
    3)
      bash LAN/VLAN/vtnVLAN-PROFILES.sh
    ;;
    4)
      echo ""
    ;;
    esac
fi
bash MENU-FIREWALL.sh