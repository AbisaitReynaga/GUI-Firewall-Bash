#!/bin/bash

################################################################################################################
# Product: Firewall
#
# Script: WAN-SETTINGS
# 
# Autor: Abisait Reynaga ~AR
# 
# Date: July 2023
#
# Description: This script run the window to configure the WAN in the firewall, below there are more details 
#               about the code and variables used in this code.
#                                                                                                            
#################################################################################################################


#################################################################################################################
# This secition is to declare statics variables
    IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    NETMASK_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    GATEWAY_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    DNS_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    VLANS_DIRECTORY="/home/user/Documents/FIREWALL/vlans/"
    INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/interfaces/"
#
#################################################################################################################


#################################################################################################################
#






function showInterfacesWAN()
{

    #GUARDA LAS INTERFACES DE RED DE IP LINK SHOW
    NETWORK_INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
    # CONVIERTE LAS INTERFACES DE RED EN UN ARRAY
    NETWORK_INTERFACES=($(echo "$NETWORK_INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))

    #this control structure - "for", add all physical interfaces to a network_interfaces array.
    for i in ${NETWORK_INTERFACES[@]}
    do
        if [[ $i != *"@"* ]] & [[ $i != *"vlan"* ]]; then
            touch ${INTERFACES_DIRECTORY}${i}.interface
        fi
    done

    #REVISAR CARPETA DE INTERFACES Y REVISAR LA CARPETA LAN
    for i in "${NETWORK_INTERFACES[@]}"; do

        if [[ $(cat "${INTERFACES_DIRECTORY}${i}.interface" | grep "#WAN INTERFACE") = "#WAN INTERFACE"  ]]; then
           NETWORK_INTERFACES_TEMP=("${NETWORK_INTERFACES_TEMP[@]}" ${i})
        elif [[ !(-s ${INTERFACES_DIRECTORY}${i}.interface) && (${i} != *"@"*) ]]; then
            NETWORK_INTERFACES_TEMP=("${NETWORK_INTERFACES_TEMP[@]}" ${i})
        fi
    done

    NETWORK_INTERFACES=(${NETWORK_INTERFACES_TEMP[@]})


    SELECTED_INTERFACE=$(dialog --title "WAN" \
   --stdout \
   --no-tags \
   --cancel-label "Back to menu" \
   --ok-label "Select" \
   --menu "Select a Network Interface:" 60 80 ${#NETWORK_INTERFACES[@]} \
   $(for ((i=0; i<${#NETWORK_INTERFACES[@]}; i++)); do echo $i "${NETWORK_INTERFACES[$i]}"; done))

    OUTPUT_ERROR=$?

   if [ $OUTPUT_ERROR -eq 1 ]; then
            ./MENU-FIREWALL.sh
   fi

}

function setWANInterface()
{
    CONTROL_SETTING='0'

    while [ $CONTROL_SETTING != '1' ]
    do
        IP_ADDRESS=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep address | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        NETMASK=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep netmask | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        GATEWAY=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep gateway | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        DNS=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep nameserver | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

            INTERFACE_SETTINGS=$(dialog --title "WAN Interface" \
            --stdout \
            --extra-button \
            --extra-label "Delete" \
            --cancel-label "Back to menu" \
            --ok-label "Apply" \
            --form "Set up Network Interface" 0 0 0 \
            "IP Adreess:" 1 1 "${IP_ADDRESS}" 1 19 30 0 \
            "Netmask" 2 1 "${NETMASK}" 2 19 30 0 \
            "Gateway:" 3 1 "${GATEWAY}" 3 19 30 0 \
            "DNS:" 4 1 "${DNS}" 4 19 30 0)
                
            OUTPUT_ERROR=$?
            echo $OUTPUT_ERROR > OUTPUT_ERROR.txt

            if [ $OUTPUT_ERROR -eq 1 ]; then
                ./WAN-SETTINGS.sh
            elif [ $OUTPUT_ERROR -eq 3 ]; then
                echo -n "" > ${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface
                ./MENU-FIREWALL.sh
            fi

            IP_ADDRESS=$(echo "$INTERFACE_SETTINGS" | sed -n 1p)
            NETMASK=$(echo "$INTERFACE_SETTINGS" | sed -n 2p)
            GATEWAY=$(echo "$INTERFACE_SETTINGS" | sed -n 3p)
            DNS=$(echo "$INTERFACE_SETTINGS" | sed -n 4p)

            if [[ $IP_ADDRESS =~ $IP_REGEX && $NETMASK =~ $NETMASK_REGEX && $GATEWAY =~ $GATEWAY_REGEX && $DNS =~ $DNS_REGEX ]]; then
                CONTROL_SETTING='1'

                echo -e "#WAN INTERFACE\n auto ${NETWORK_INTERFACES[$SELECTED_INTERFACE]}\n iface ${NETWORK_INTERFACES[$SELECTED_INTERFACE]} inet static\n \
                address $IP_ADDRESS\n \
                netmask $NETMASK\n \
                gateway $GATEWAY\n \
                nameserver $DNS" > ${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[${SELECTED_INTERFACE}]}.interface
            else
                #PENDIENTE LO VISUAL
                dialog --colors --title "ERROR" \
                    --msgbox "\Zb\Z1One or more parameters are incorrect, check them and try again\Zn" 0 0
            fi
    done

    
}

function setNetworkFile()
{
    # Dejar en blanco el archivo /etc/network/interfaces
       echo -n "" > /etc/network/interfaces

    INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/interfaces/*"
    VLANS_DIRECTORY="/home/user/Documents/FIREWALL/vlans/*"

    for i in $INTERFACES_DIRECTORY
    do
        interface_name=$(echo "$i" | sed 's/\/home\/user\/Documents\/FIREWALL\/interfaces\///')
        if [[ $(cat "$i" | grep "#WAN INTERFACE") = "#WAN INTERFACE"  ]]; then
            cat "$i" >>  /etc/network/interfaces
        else
            continue
        fi
    done        
    echo -e "\n" >> /etc/network/interfaces
    for i in $INTERFACES_DIRECTORY
    do
        interface_name=$(echo "$i" | sed 's/\/home\/user\/Documents\/FIREWALL\/interfaces\///')
        if [[ $(cat "$i" | grep "#LAN INTERFACE") = "#LAN INTERFACE"  ]]; then
            cat "$i" >>  /etc/network/interfaces
        else
            continue
        fi
    done

    for i in $VLANS_DIRECTORY
    do
        interface_name=$(echo "$i" | sed 's/\/home\/user\/Documents\/FIREWALL\/vlans\///')
        if [[ $(cat "$i" | grep "#VLAN INTERFACE") = "#VLAN INTERFACE"  ]]; then
            cat "$i" >>  /etc/network/interfaces
        else
            continue
        fi
    done
    echo -e "\n" >> /etc/network/interfaces
}




  showInterfacesWAN
  setWANInterface
  setNetworkFile

./MENU-FIREWALL.sh