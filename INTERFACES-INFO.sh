#!/bin/bash

INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/interfaces/"
INTERFACES_FILES=()
COUNTER=0

if [[ $(ls -A "$INTERFACES_DIRECTORY") ]]; then
    for i in "$INTERFACES_DIRECTORY"/*
    do
        if [[ -s "$i" ]]; then
            INTERFACES_FILES+=("$i")
            ((COUNTER++))
        fi
    done

    if [[ $COUNTER -ne 0 ]]; then
        touch /home/user/Documents/FIREWALL/interfaces/info.interfaces
        for i in "${INTERFACES_FILES[@]}"
        do
            cat "$i" >> /home/user/Documents/FIREWALL/interfaces/info.interfaces
            echo "------------------------------" >> /home/user/Documents/FIREWALL/interfaces/info.interfaces
        done
        dialog \
            --title "Information about interfaces" \
            --ok-label "Back to Menu" \
            --msgbox "$(cat /home/user/Documents/FIREWALL/interfaces/info.interfaces)" 0 0
    else
        dialog --colors \
            --title "ERROR" \
             --ok-label "Back to Menu" \
            --msgbox "\Zb\Z1No network interfaces configured...\Zn" 5 70   
    fi

else
    dialog --colors \
        --title "ERROR" \
        --msgbox "\Zb\Z1No network interfaces configured\Zn" 5 70   
fi

rm /home/user/Documents/FIREWALL/interfaces/info.interfaces

./MENU-FIREWALL.sh