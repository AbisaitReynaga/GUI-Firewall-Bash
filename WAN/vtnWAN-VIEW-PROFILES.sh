#!/bin/bash
INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
INTERFACES=($(echo "$INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))
PROFILES=()
PROFILE_SELECTED=""
WAN_COUNTER=0
FILES=$(find INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_FILES=$(find INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory

#DEFINE FUNCTIONS

function WAN_INTERFACE_EMPTY()
{
   dialog --title "VIEW WAN INTERFACE" \
   --msgbox "There is not a profile yet registred" 0 0
}

function WAN_COUNTER_INTERFACES()
{
    for ARCHIVO in INTERFACES/*; 
    do
        if [ "$(cat "$ARCHIVO" | grep "#WAN INTERFACE")" = "#WAN INTERFACE" ]; then
            WAN_COUNTER=$((LAN_COUNTER + 1))
        fi
    done

}

function LIST_PROFILES_WAN()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#WAN INTERFACE")" = "#WAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "")
        fi
    done

}

function WAN_INTERFACE()
{
    PROFILE_SELECTED=$(dialog --title "VIEW WAN INTERFACE" \
    --colors \
    --stdout \
    --ok-label "View interface" \
    --cancel-label "Back" \
    --menu "Select a profile:" 0 0 ${#PROFILES[@]} \
    "${PROFILES[@]}")
}

WAN_COUNTER_INTERFACES

if [ $EMPTY_FILES -eq $FILES ]; then
    WAN_INTERFACE_EMPTY
    bash WAN/vtnWAN-MENU.sh
else
    if [ $WAN_COUNTER -eq 0 ]; then
        WAN_INTERFACE_EMPTY
        bash WAN/vtnWAN-MENU.sh
    else
        LIST_PROFILES_WAN
        WAN_INTERFACE
    fi
fi

case $? in
0)
    echo "${PROFILE_SELECTED}" > WAN/OUTPUT
    bash WAN/vtnWAN-VIEW-INTERFACE.sh
;;
1)
    bash WAN/vtnWAN-MENU.sh
;;

esac 