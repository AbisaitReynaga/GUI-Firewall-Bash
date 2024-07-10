OUTPUT=$(dialog  --title "Interface Eth0" \
        --colors \
        --stdout \
        --ok-label "Apply" \
        --cancel-label "Cancel" \
        --form "Edit the conection" 0 0 0 \
        "VLAN name: " 1 1 "VLAN 1" 1 23 30 0   \
        "VLAN number: " 2 1 "" 2 23 30 0  \
        "Address: " 3 1 "" 3 23 30 0  \
        "Network: " 4 1 "" 4 23 30 0  \
        "Netmask: " 5 1 "" 5 23 30 0  \
        "Broadcast: " 6 1 "" 6 23 30 0)



if [ $? -eq 0 ]; then
    echo "Apply selected"
else
    bash LAN/vtnLAN-MENU.sh
fi
