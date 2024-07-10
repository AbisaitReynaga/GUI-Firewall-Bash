#!/bin/bash

OPC_MENU=$(dialog --title "Services" \
   --colors \
   --stdout \
   --ok-label "Select" \
   --cancel-label "Back to menu" \
   --menu "Select a option:" 0 0 0 \
   1 "OpenVPN" \
   2 "DHCP")

if [ $? -eq 0 ]; then
    case $OPC_MENU in
            1)
                bash SERVICES/OPENVPN/vtnOPENVPN-MENU.sh
            ;;
            2)
                bash SERVICES/DHCP/vtnDHCP-PROFILES.sh
            ;;
    esac
else
    bash MENU-FIREWALL.sh
fi