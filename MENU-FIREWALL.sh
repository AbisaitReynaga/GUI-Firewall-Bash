#!/bin/bash
OPC_MENU=$(dialog --title "G-Firewall" \
   --colors \
   --stdout \
   --help-label "Back to menu" \
   --menu "Select a option:" 0 0 0 \
   1 "WAN Settings" \
   2 "LAN Settings" \
   3 "Services" \
   4 "About G-Firewall")  

case $OPC_MENU in
            1)
                bash WAN/vtnWAN-MENU.sh
            ;;
            2)
                bash LAN/vtnLAN-MENU.sh
            ;;
            3)
                bash SERVICES/vtnSERVICES-MENU.sh
            ;;
            4)
                echo "LAN Settings"
            ;;
            5)
                echo "WAN Settings"
            ;;
            *) 
                echo _"No seleccionado"
            ;;
        esac               