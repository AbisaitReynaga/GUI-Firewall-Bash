
PROFILES=()
INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
INTERFACES=($(echo "$INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))
LAN_COUNTER=0
FILES=$(find VLAN_INTERFACES -type f | wc -l) #This variable stores the number of files contained in INTERFACE directory
EMPTY_FILES=$(find VLAN_INTERFACES -type f -empty | wc -l) #This variable stores the number of empty files contained in INTERFACE directory

function LAN_INTERFACE_EMPTY()
{
    dialog --title "VLAN PROFILE" \
   --colors \
   --stdout \
   --no-ok \
   --help-button \
   --help-label "Back" \
   --msgbox "There is not a LAN profile yet registred" 0 0
}

function VLAN_INTERFACE_EMPTY()
{
   dialog --title "VLAN PROFILE" \
   --colors \
   --stdout \
   --ok-label "Add" \
   --help-button \
   --help-label "Back" \
   --msgbox "There is not a profile yet registred" 0 0
}

function VLAN_COUNTER_INTERFACES()
{
    for ARCHIVO in INTERFACES/*; do
        if [ "$(cat "$ARCHIVO" | grep "#LAN INTERFACE")" = "#LAN INTERFACE" ]; then
            LAN_COUNTER=$((LAN_COUNTER + 1))
        fi
    done

}

function LIST_PROFILES()
{
    for ARCHIVO in VLAN_INTERFACES/*; do
        if [ "$(cat $ARCHIVO | grep "#VLAN INTERFACE")" = "#VLAN INTERFACE" ]; then
            PROFILES+=("$(cat $ARCHIVO | grep "#PROFILE" | sed 's/#PROFILE //')" "")
        fi
    done

}

VLAN_COUNTER_INTERFACES


if [ $LAN_COUNTER -eq 0 ]; then
    LAN_INTERFACE_EMPTY
    bash LAN/vtnLAN-MENU.sh
else
    if [ $FILES -eq $EMPTY_FILES ]; then
        VLAN_INTERFACE_EMPTY
    else
    LIST_PROFILES
    PROFILE_SELECTED=$(dialog --title "VLAN PROFILES" \
        --colors \
        --stdout \
        --ok-label "View interface" \
        --cancel-label "Back" \
        --menu "Select a profile:" 0 0 ${#PROFILES[@]} \
        "${PROFILES[@]}")
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