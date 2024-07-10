#!/bin/bash

OPC_MENU=$(dialog --title "WAN Settings" \
        --colors \
        --stdout \
        --ok-label "Select" \
        --cancel-label "Back to menu" \
        --menu "Select an option:" 0 0 0 \
        1 "Configure WAN interface" \
        2 "View WAN interface")

case $? in
0)
    case $OPC_MENU in
    1)
        bash WAN/vtnWAN-PROFILES.sh
    ;;
    2)
        echo "View WAN interface"
    ;;
    esac
;;
1)
    bash MENU-FIREWALL.sh
;;
esac
