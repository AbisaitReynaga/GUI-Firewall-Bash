#!/bin/bash

PROFILE=$(dialog --title "VLAN Profiles" \
   --colors \
   --stdout \
   --extra-button \
   --ok-label "Add" \
   --extra-label "Modify" \
   --help-button \
   --help-label "Back" \
   --cancel-label "Delete" \
   --menu "Select a profile:" 0 0 0 \
   1 "VLAN 1" \
   2 "VLAN 2" \
   3 "VLAN 3" )

   case $? in 
    0)
        bash LAN/VLAN/vtnVLAN-INTERFACES.sh
    ;;
    1)
        echo ""
    ;;
    2) 
        bash LAN/vtnLAN-SETUP.sh
    ;;
    3)
        bash LAN/VLAN/vtnVLAN-SETUP.sh
    ;;
    esac