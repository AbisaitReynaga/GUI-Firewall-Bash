#!/bin/bash

#!/bin/bash
PROFILES=()
LAN_COUNTER=0
VLAN_COUNTER=0

FILES_INTERFACES=$(find INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_INTERFACES=$(find INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory

FILES_VLAN_INTERFACES=$(find VLAN_INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_VLAN_INTERFACES=$(find VLAN_INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory


function LIST_PROFILES_LAN()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "$(cat $ARCHIVO | grep "#DHCP" | sed 's/#DHCP //')")
        fi
    done
}
function LIST_PROFILES_VLAN()
{
    for ARCHIVO in VLAN_INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#VLAN INTERFACE")" = "#VLAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "$(cat $ARCHIVO | grep "#DHCP" | sed 's/#DHCP //')")
        fi
    done
}

LIST_PROFILES_LAN
LIST_PROFILES_VLAN

        PROFILE_SELECTED=$(dialog --title "DHCP SERVICES" \
            --colors \
            --stdout \
            --extra-button \
            --ok-label "Enable" \
            --extra-label "Disable" \
            --help-button \
            --help-label "View" \
            --cancel-label "Back" \
            --menu "Select a profile:" 0 0 ${#PROFILES[@]} \
            "${PROFILES[@]}")   
   case $? in 
    0)
        echo "${PROFILE_SELECTED}" > SERVICES/DHCP/OUTPUT
        bash SERVICES/DHCP/vtnDHCP-SETUP.sh
    ;;
    1)
        echo ""
    ;;
    2) 
        echo "" 
    ;;
    3)
        echo "" 
        #echo "${PROFILE_SELECTED}" > LAN/OUTPUT
        #bash LAN/vtnLAN-SETUP-MODIFY.sh
    ;;
    esac