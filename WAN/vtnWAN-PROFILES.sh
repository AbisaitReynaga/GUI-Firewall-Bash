#!/bin/bash
PROFILES=()
OUT=0
INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
INTERFACES=($(echo "$INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))

FILES=$(find INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_FILES=$(find INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory

for ARCHIVO in INTERFACES/*; do
    if [ -s $ARCHIVO ]; then
        PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "")
    fi
done


#DEFINE FUNCTIONS
function WAN_INTERFACE_EMPTY()
{
   dialog --title "WAN INTERFACE" \
   --colors \
   --stdout \
   --ok-label "Add" \
   --help-button \
   --help-label "Back" \
   --msgbox "There is not a profile yet registred" 0 0
}

function WAN_INTERFACE() {


    PROFILE_SELECTED=$(dialog --title "WAN INTERFACE" \
    --colors \
    --stdout \
    --extra-button \
    --ok-label "Add" \
    --extra-label "Modify" \
    --help-button \
    --help-label "Back" \
    --cancel-label "Delete" \
    --menu "Select a profile:" 0 0 ${#PROFILES[@]} \
    "${PROFILES[@]}")
}


if [ $EMPTY_FILES -eq $FILES ]; then
    WAN_INTERFACE_EMPTY
else 
    WAN_INTERFACE
fi

case $? in 
0)
    bash WAN/vtnWAN-INTERFACES.sh
;;
1)
    if [ $EMPTY_FILES -ne $FILES ]; then
        for ARCHIVO in INTERFACES/*; 
        do
            if [ "$(cat "$ARCHIVO" | grep "#PROFILE" | sed 's/#PROFILE //')" = "$(cat WAN/OUTPUT)" ]; then
                break
            fi
        done
        rm $ARCHIVO
    fi
    bash WAN/vtnWAN-PROFILES.sh
;;
2) 
    bash WAN/vtnWAN-MENU.sh
;;
3)
    echo "${PROFILE_SELECTED}" > WAN/OUTPUT
    bash WAN/vtnWAN-SETUP-MODIFY.sh
;;
esac