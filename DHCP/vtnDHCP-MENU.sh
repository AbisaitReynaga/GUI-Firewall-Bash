#!/bin/bash

OPC_MENU=$(dialog --title "WAN Settings" \
        --colors \
        --stdout \
        --ok-label "Select" \
        --cancel-label "Back to menu" \
        --menu "Select an option:" 0 0 0 \
        1 "DHCP Dynamic" \
        2 "DHCP Estatic")

case $? in
0)
    case $OPC_MENU in
    1)
        bash DHCP/vtnDHCP-INTERFACES.sh
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