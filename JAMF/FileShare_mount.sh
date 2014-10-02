#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2014-10-02

### Description 
# I'm looking for the domain_name_server section of  the ipconfig command.  
# I assume I'm looking for the LAST IP address that is handed via your DHCP server.
# This was created for JNUC 2014 Policies presentation, there are always better ways to do things
# for your environment.  

### Variables
DNS_SERVER="10.13.12.122"
FILE_SERVER="host.domain.tld"
SHARE_NAME="Shared"
PROTOCOL="afp"

WIFI=`networksetup -listnetworkserviceorder | grep "Wi-Fi" | tail -1 | awk -F ": " '{print $NF}' | sed 's/)//g'`
ETHERNET=`networksetup -listnetworkserviceorder | grep "Ethernet" | tail -1 | awk -F ": " '{print $NF}' | sed 's/)//g'`

WIFI_DNS=`ipconfig getpacket "${WIFI}" | awk '/domain_name_server/ {print $NF}' | sed 's/}//g'`
ETH_DNS=`ipconfig getpacket "${ETHERNET}" | awk '/domain_name_server/ {print $NF}' | sed 's/}//g'`

### Functions
net_mount() {
	open "${PROTOCOL}://${FILE_SERVER}/${SHARE_NAME}/"
}

[[  "${ETH_DNS}" == "${DNS_SERVER}" ]] && { net_mount; exit 0; } || { echo "${ETH_DNS}"; }
[[  "${WIFI_DNS}" == "${DNS_SERVER}" ]] && { net_mount; exit 0; } || { echo "${WIFI_DNS}"; }

echo "Not on the network.  I'll stop now."
exit 0
