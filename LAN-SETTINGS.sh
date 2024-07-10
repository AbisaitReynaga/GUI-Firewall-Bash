#!/bin/bash
################################################################################################################
# Product: Firewall
#
# Script: LAN-SETTINGS
# 
# Developer: Abisait Reynaga ~AR
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
        NETWORK_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
        BROADCAST_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
        VLANS_DIRECTORY="/home/user/Documents/FIREWALL/vlans/"
        LAN_DIRECTORY="/home/user/Documents/FIREWALL/lan/"
        WAN_DIRECTORY="/home/user/Documents/FIREWALL/wan/"
        INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/interfaces/"
#
#################################################################################################################


#################################################################################################################
#Function declaration
function showMenuLANSettings()
{
    SELECTED_OPTION=$(dialog --title "LAN" \
    --no-tags \
    --no-cancel \
    --ok-label "Back to menu" \
    --stdout \
    --menu "Options" 600 300 3 \
    1 "Set up LAN" \
    2 "Set up a newVLAN" \
    4 "Modidy VLAN" \
    3 "VLAN's Interfaces")

}

function showInterfacesLAN()
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

        if [[ $(cat "${INTERFACES_DIRECTORY}${i}.interface" | grep "#LAN INTERFACE") = "#LAN INTERFACE"  ]]; then
           NETWORK_INTERFACES_TEMP=("${NETWORK_INTERFACES_TEMP[@]}" ${i})
        elif [[ !(-s ${INTERFACES_DIRECTORY}${i}.interface) && (${i} != *"@"*) ]]; then
            NETWORK_INTERFACES_TEMP=("${NETWORK_INTERFACES_TEMP[@]}" ${i})
        fi
    done

 NETWORK_INTERFACES=(${NETWORK_INTERFACES_TEMP[@]})


    SELECTED_INTERFACE=$(dialog --title "LAN Interface" \
   --stdout \
   --no-tags \
   --cancel-label "Back to menu" \
   --ok-label "Select" \
   --menu "Select a Network Interface:" 60 80 ${#NETWORK_INTERFACES[@]} \
   $(for ((i=0; i<${#NETWORK_INTERFACES[@]}; i++)); do echo $i "${NETWORK_INTERFACES[$i]}"; done))

    OUTPUT_ERROR=$?
   if [ $OUTPUT_ERROR -ne 0 ]; then
            ./MENU-FIREWALL.sh
   fi
}

function setLANInterface()
{

    
    CONTROL_SETTING='0'
    while [ $CONTROL_SETTING != '1' ]
 do
    IP_ADDRESS=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep address | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    NETWORK=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep network | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    NETMASK=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep netmask | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    BROADCAST=$(cat "${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep broadcast | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

    echo $IP_ADDRESS
    
    INTERFACE_SETTINGS=$(dialog --title "LAN" \
    --stdout \
    --extra-button \
    --extra-label "Delete" \
    --cancel-label "Back to menu" \
    --ok-label "Apply" \
    --form "Set up Network Interface" 0 0 0 \
    "IP Address:" 1 1 "${IP_ADDRESS}" 1 19 30 0 \
    "Network:" 2 1 "${NETWORK}" 2 19 30 0 \
    "Netmask:" 3 1 "${NETMASK}" 3 19 30 0 \
    "Broadcast:" 4 1 "${BROADCAST}" 4 19 30 0)
               
    OUTPUT_ERROR=$?

    if [ $OUTPUT_ERROR -eq 1 ]; then
        ./LAN-SETTINGS.sh
    elif [ $OUTPUT_ERROR -eq 3 ]; then
            echo -n "" > ${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface
            ./MENU-FIREWALL.sh
    fi

    IP_ADDRESS=$(echo "$INTERFACE_SETTINGS" | sed -n 1p)
    NETWORK=$(echo "$INTERFACE_SETTINGS" | sed -n 2p)
    NETMASK=$(echo "$INTERFACE_SETTINGS" | sed -n 3p)
    BROADCAST=$(echo "$INTERFACE_SETTINGS" | sed -n 4p)

    if [[ $IP_ADDRESS =~ $IP_REGEX && $NETMASK =~ $NETMASK_REGEX && $NETWORK =~ $NETWORK_REGEX && $BROADCAST =~ $BROADCAST_REGEX ]]; then
        CONTROL_SETTING='1'
        echo -e "#LAN INTERFACE\n auto ${NETWORK_INTERFACES[$SELECTED_INTERFACE]}\n iface ${NETWORK_INTERFACES[$SELECTED_INTERFACE]} inet static\n \
        address $IP_ADDRESS\n \
        network $NETWORK\n \
        netmask $NETMASK\n \
        broadcast $BROADCAST" > ${INTERFACES_DIRECTORY}${NETWORK_INTERFACES[${SELECTED_INTERFACE}]}.interface
    else
        dialog --title "ERROR" \
        --colors \
        --msgbox "\Zb\Z1One or more parameters are incorrect, check them and try again\Zn" 0 0
    fi

 done
}

#AGREGAR LA PARTE QUE VERIFICA QUE SI HAYA CONFIGURACIONES EN LA LAN
function showInterfacesToVLAN()
{
    #GUARDA LAS INTERFACES DE RED DE IP LINK SHOW
    NETWORK_INTERFACES=$(ip -o -br link show | awk '!/lo/{print $1}' | tr '\n' ' ')
    # CONVIERTE LAS INTERFACES DE RED EN UN ARRAY
    NETWORK_INTERFACES=($(echo "$NETWORK_INTERFACES" | awk '{for(i=1; i<=NF; i++) print $i}'))

   for i in ${NETWORK_INTERFACES[@]}
    do
        if [[ $i != *"@"* ]] & [[ $i != *"vlan"* ]]; then
            touch ${INTERFACES_DIRECTORY}${i}.interface
        fi
    done

    #REVISAR CARPETA DE INTERFACES Y REVISAR LA CARPETA LAN
    for i in "${NETWORK_INTERFACES[@]}"; do

        if [[ $(cat "${INTERFACES_DIRECTORY}${i}.interface" | grep "#LAN INTERFACE") = "#LAN INTERFACE"  ]]; then
           NETWORK_INTERFACES_TEMP=("${NETWORK_INTERFACES_TEMP[@]}" ${i})
        else
            continue
        fi
    done
    NETWORK_INTERFACES=(${NETWORK_INTERFACES_TEMP[@]})

    echo "${#NETWORK_INTERFACES[@]}"

    if [[ ${#NETWORK_INTERFACES[@]} -ne 0 ]]; then 
        SELECTED_INTERFACE=$(dialog --title "LAN Interface" \
        --stdout \
        --no-tags \
        --cancel-label "Back to menu" \
        --ok-label "Select" \
        --menu "Select a Network Interface:" 60 80 ${#NETWORK_INTERFACES[@]} \
        $(for ((i=0; i<${#NETWORK_INTERFACES[@]}; i++)); do echo $i "${NETWORK_INTERFACES[$i]}"; done))

            OUTPUT_ERROR=$?
        if [ $OUTPUT_ERROR -ne 0 ]; then
                    ./MENU-FIREWALL.sh
        fi
    else
        dialog --colors \
                    --title "ERROR" \
                    --ok-label "Back to Menu" \
                    --msgbox "\Zb\Z1No network interfaces configured...\Zn" 5 70 
                    ./LAN-SETTINGS.sh 
    fi
}

#PENDIENTE
function setVLAN()
{
    CONTROL_SETTING='0'
    while [ $CONTROL_SETTING != '1' ]
 do
    #IP_ADDRESS=$(cat "${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep address | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    ##NETWORK=$(cat "${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep network | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    #NETMASK=$(cat "${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep netmask | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    #BROADCAST=$(cat "${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface" | grep broadcast | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
    
    INTERFACE_SETTINGS=$(dialog --title "VLAN" \
    --stdout \
    --cancel-label "Back to menu" \
    --ok-label "Apply" \
    --form "Set up VLAN Interface" 0 0 0 \
    "VLAN Number:" 1 1 "${VLAN}" 1 19 30 0 \
    "IP Address:" 2 1 "${IP_ADDRESS}" 2 19 30 0 \
    "Network:" 3 1 "${NETWORK}" 3 19 30 0 \
    "Netmask:" 4 1 "${NETMASK}" 4 19 30 0 \
    "Broadcast:" 5 1 "${BROADCAST}" 5 19 30 0)
               
    OUTPUT_ERROR=$?

    if [ $OUTPUT_ERROR -ne 0 ]; then
        ./LAN-SETTINGS.sh
    fi
    VLAN=$(echo "$INTERFACE_SETTINGS" | sed -n 1p)
    IP_ADDRESS=$(echo "$INTERFACE_SETTINGS" | sed -n 2p)
    NETWORK=$(echo "$INTERFACE_SETTINGS" | sed -n 3p)
    NETMASK=$(echo "$INTERFACE_SETTINGS" | sed -n 4p)
    BROADCAST=$(echo "$INTERFACE_SETTINGS" | sed -n 5p)

    if [[ $IP_ADDRESS =~ $IP_REGEX && $NETMASK =~ $NETMASK_REGEX && $NETWORK =~ $NETWORK_REGEX && $BROADCAST =~ $BROADCAST_REGEX ]]; then
        CONTROL_SETTING='1'
        echo -e "#VLAN INTERFACE\n#VLAN_NUMBER ${VLAN}\nauto vlan${VLAN}\niface vlan${VLAN} inet static\n \
        address $IP_ADDRESS\n \
        network $NETWORK\n \
        netmask $NETMASK\n \
        broadcast $BROADCAST \n \
        vlan_raw_device ${NETWORK_INTERFACES[$SELECTED_INTERFACE]}" > "${VLANS_DIRECTORY}"vlan"${VLAN}@${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface"

    else
        dialog --title "ERROR" \
        --colors \
        --msgbox "\Zb\Z1One or more parameters are incorrect, check them and try again\Zn" 0 0
    fi
 done
}

function setNetworkFile()
{
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

function informationVLAN2()
{
            INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/vlans/"
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
                touch /home/user/Documents/FIREWALL/vlans/vlan.interfaces
                for i in "${INTERFACES_FILES[@]}"
                do
                    cat "$i" >> /home/user/Documents/FIREWALL/vlans/vlan.interfaces
                    echo "------------------------------" >> /home/user/Documents/FIREWALL/vlans/vlan.interfaces
                done
                dialog \
                    --title "Information about interfaces" \
                    --ok-label "Back to Menu" \
                    --msgbox "$(cat /home/user/Documents/FIREWALL/vlans/vlan.interfaces)" 0 0
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
        rm /home/user/Documents/FIREWALL/vlans/vlan.interfaces

        ./MENU-FIREWALL.sh
}

function modifyVLAN()
{
    INTERFACES_DIRECTORY="/home/user/Documents/FIREWALL/vlans/"
    INTERFACES_NAMES=()
    INTERFACES_FILES=()

    if [[ $(ls -A "$INTERFACES_DIRECTORY") ]]; then

        for i in "$INTERFACES_DIRECTORY"*
        do
            if [[ -s ${i} ]]; then
                INTERFACES_NAMES+=($(echo "${i}" | awk -F '/' '{print $7}' | awk -F '.' '{print $1}'))
                INTERFACES_FILES+=("${i}")
                echo $i
            fi
        done
                echo "${INTERFACES_NAMES[@]}"
        SELECTED_INTERFACE=$(dialog --title "LAN Interface" \
    --stdout \
    --no-tags \
    --cancel-label "Back to menu" \
    --ok-label "Select" \
    --menu "Select a VLAN Interface:" 60 80 ${#INTERFACES_NAMES[@]} \
    $(for ((i=0; i<${#INTERFACES_NAMES[@]}; i++)); do echo $i "${INTERFACES_NAMES[$i]}"; done))
        VLAN=$(cat "${INTERFACES_FILES[$SELECTED_INTERFACE]}" | grep VLAN_NUMBER| awk '{print $2}')
        IP_ADDRESS=$(cat "${INTERFACES_FILES[$SELECTED_INTERFACE]}" | grep address | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        NETWORK=$(cat "${INTERFACES_FILES[$SELECTED_INTERFACE]}" | grep network | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        NETMASK=$(cat "${INTERFACES_FILES[$SELECTED_INTERFACE]}" | grep netmask | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        BROADCAST=$(cat "${INTERFACES_FILES[$SELECTED_INTERFACE]}" | grep broadcast | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

        INTERFACE_SETTINGS=$(dialog --title "VLAN" \
        --stdout \
        --extra-button \
        --extra-label "Delete" \
        --cancel-label "Back to menu" \
        --ok-label "Apply" \
        --form "Set up Network Interface" 0 0 0 \
        "VLAN Number:" 1 1 "${VLAN}" 1 19 30 0 \
        "IP Address:" 2 1 "${IP_ADDRESS}" 2 19 30 0 \
        "Network:" 3 1 "${NETWORK}" 3 19 30 0 \
        "Netmask:" 4 1 "${NETMASK}" 4 19 30 0 \
        "Broadcast:" 5 1 "${BROADCAST}" 5 19 30 0)
        if [[ $IP_ADDRESS =~ $IP_REGEX && $NETMASK =~ $NETMASK_REGEX && $NETWORK =~ $NETWORK_REGEX && $BROADCAST =~ $BROADCAST_REGEX ]]; then
            CONTROL_SETTING='1'
            echo -e "#VLAN INTERFACE\n#VLAN_NUMBER ${VLAN}\nauto vlan${VLAN}\niface vlan${VLAN} inet static\n \
            address $IP_ADDRESS\n \
            network $NETWORK\n \
            netmask $NETMASK\n \
            broadcast $BROADCAST \n \
            vlan_raw_device ${NETWORK_INTERFACES[$SELECTED_INTERFACE]}" > "${VLANS_DIRECTORY}"vlan"${VLAN}@${NETWORK_INTERFACES[$SELECTED_INTERFACE]}.interface"

        else
            dialog --title "ERROR" \
            --colors \
            --msgbox "\Zb\Z1One or more parameters are incorrect, check them and try again\Zn" 0 0
        fi
                


    else
        dialog --colors \
            --title "ERROR" \
            --msgbox "\Zb\Z1No VLAN's configured\Zn" 5 70   
    fi
}

function informationVLAN()
{
    VLANS_DIRECTORY="/home/user/Documents/FIREWALL/vlans/*"
    VLAN=()
    
    for i in $VLANS_DIRECTORY
    do

        VLAN+=("$i")
    done  



    OPC=0
    CNT=0

    while [ $OPC -ne 3 ]
    do

        INTERFACE_NAME=$(echo "${VLAN[$CNT]}" | sed 's/\/home\/user\/Documents\/FIREWALL\/vlans\///')
        IP_ADDRESS=$(cat "${VLAN[$CNT]}" | grep address | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        NETWORK=$(cat "${VLAN[$CNT]}" | grep network | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        NETMASK=$(cat "${VLAN[$CNT]}" | grep netmask | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')
        BROADCAST=$(cat "${VLAN[$CNT]}" | grep broadcast | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."$4}')

        dialog --ok-label "ANTERIOR" \
        --cancel-label "SIGUIENTE" \
        --extra-button \
        --extra-label "SALIR" \
        --mixedform "PARAMETROS VLAN: $INTERFACE_NAME" 0 0 0 \
        "DIRECCION IP:" 1 0 "${IP_ADDRESS}" 1 20 20 20 2 \
        "NETWORK: " 2 0 "${NETWORK}" 2 20 20 20 2 \
        "NETMASK: " 3 0 "${NETMASK}" 3 20 20 20 2 \
        "BROADCAST: " 4 0 "${BROADCAST}" 4 20 20 20 2

        OPC=$?
        if [ $OPC -eq 0 ]; then
            CNT=$((CNT-1))
            if [ $CNT -lt 0 ]; then
                CNT=$((CNT+${#VLAN[@]}))
            fi
        elif [ $OPC -eq 1 ]; then
            CNT=$((CNT+1))
            if [ $CNT -ge ${#VLAN[@]} ]; then
                CNT=0
            fi
        fi
    
    done



}

showMenuLANSettings

if [ $SELECTED_OPTION -eq '1' ]; then
    showInterfacesLAN
    setLANInterface

elif [ $SELECTED_OPTION -eq '2' ]; then
    showInterfacesToVLAN
    setVLAN
elif [ $SELECTED_OPTION -eq '3' ]; then
    informationVLAN2
elif [ $SELECTED_OPTION -eq '4' ]; then
    modifyVLAN
fi

setNetworkFile    
./MENU-FIREWALL.sh