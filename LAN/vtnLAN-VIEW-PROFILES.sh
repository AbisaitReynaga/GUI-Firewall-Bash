#!/bin/bash


PROFILES=()
PROFILE_SELECTED=""
LAN_COUNTER=0
FILES=$(find INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_FILES=$(find INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory

#DEFINE FUNCTIONS

function LAN_INTERFACE_EMPTY()
{
   dialog --title "VIEW LAN INTERFACE" \
   --msgbox "There is not a profile yet registred" 0 0
}

function LAN_COUNTER_INTERFACES()
{
    for ARCHIVO in INTERFACES/*; 
    do
        if [ "$(cat "$ARCHIVO" | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            LAN_COUNTER=$((LAN_COUNTER + 1))
        fi
    done

}

function LIST_PROFILES_LAN()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "")
        fi
    done

}

function LAN_INTERFACE()
{
    PROFILE_SELECTED=$(dialog --title "VIEW LAN INTERFACE" \
    --colors \
    --stdout \
    --ok-label "View interface" \
    --cancel-label "Back" \
    --menu "Select a profile:" 0 0 ${#PROFILES[@]} \
    "${PROFILES[@]}")
}

LAN_COUNTER_INTERFACES

if [ $EMPTY_FILES -eq $FILES ]; then
    LAN_INTERFACE_EMPTY
    bash LAN/vtnLAN-MENU.sh
else
    if [ $LAN_COUNTER -eq 0 ]; then
        LAN_INTERFACE_EMPTY
        bash LAN/vtnLAN-MENU.sh
    else
        LIST_PROFILES_LAN
        LAN_INTERFACE
    fi
fi

case $? in
0)
    echo "${PROFILE_SELECTED}" > VLAN/OUTPUT
    bash VLAN/vtnVLAN-VIEW-INTERFACE.sh
;;
1)
    bash LAN/vtnLAN-MENU.sh
;;

esac 