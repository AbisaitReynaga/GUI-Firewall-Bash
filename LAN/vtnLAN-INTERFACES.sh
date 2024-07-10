#!/bin/bash


INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
INTERFACES=($(echo "$INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))

for i in ${INTERFACES[@]}
do
    if [[ $i != *"@"* ]] & [[ $i != *"vlan"* ]]; then
        touch INTERFACES/${i}
    fi
done

INTERFACES=()
for ARCHIVO in INTERFACES/*; do
    if [ -s "$ARCHIVO" ]; then
        continue
    else
        INTERFACES+=("$(echo "$ARCHIVO" |  sed 's/INTERFACES\///')")
    fi
done

OPC_SELECTED=$(dialog \
  --stdout \
  --no-tags \
  --ok-label "Select" \
  --cancel-label "Back" \
  --title "Network Interfaces" \
  --menu "Select a network interface" 0 0 "${#INTERFACES[@]}" \
    $(for ((i=0; i<${#INTERFACES[@]}; i++)); do echo $i "${INTERFACES[$i]}"; done) )

if [ $? -eq 0 ]; then
    echo "#INTERFACE ${INTERFACES[$OPC_SELECTED]}" > LAN/OUTPUT
    bash LAN/vtnLAN-SETUP.sh
else
    bash LAN/vtnLAN-PROFILES.sh
fi
