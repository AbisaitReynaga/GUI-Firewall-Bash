#!/bin/bash

PROFILE=$(dialog --title "LAN Profiles" \
   --colors \
   --stdout \
   --extra-button \
   --ok-label "Add" \
   --extra-label "Modify" \
   --help-button \
   --help-label "Back" \
   --cancel-label "Delete" \
   --menu "Select a profile:" 0 0 0 \
   1 "Profile 1" \
   2 "Profile 2" \
   3 "Profile 3" )

   case $? in 
    0)
        bash LAN/vtnLAN-INTERFACES.sh
    ;;
    1)
        echo ""
    ;;
    2) 
        bash LAN/vtnLAN-MENU.sh
    ;;
    3)
        bash LAN/vtnLAN-SETUP.sh
    ;;
    esac