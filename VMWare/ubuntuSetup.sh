#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-3-28

# Modified by
# Version 


### Description 
# Goal is to have a script that performs the basic setup needs for a brand new ubuntu server.

### Assumptions
# -	You are installing the server from Ubuntu's setup assistant, not using VMware's "easy" 
# 	setup assistant.  The reason for this is Ubuntu will ask you for a custom hostname.
# -	There is no encryption on the volume
# -	The Partitioning method is the default "use entire disk w/ LVM"

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="disable"
logDate=`date "+%Y-%m-%d"`
logDateTime=`date "+%Y-%m-%d_%H:%M:%S"`
log_dir="/var/log/${logtag}"
LogFile="${logtag}-${logDate}.log"

# Script Variables

# Script Functions
verifyRoot () {
    #Make sure we are root before proceeding.
    [ `id -u` != 0 ] && { echo "$0: Please run this as root."; exit 0; }
}

logThis () {
	# Output to stdout and LogFile.
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${LogFile}"; }
}

init () {
	# Make our log directory
    [ ! -d $log_dir ] && { mkdir $log_dir; }

    # Now make our log file
    if [ -d $log_dir ]; then
        [ ! -e "${log_dir}/${LogFile}" ] && { touch $log_dir/${LogFile}; logThis "Log file ${LogFile} created"; logThis "Date: ${logDateTime}"; }
    else
        echo "Error: Could not create log file in directory $log_dir."
        exit 1
    fi
    echo " " >> "${log_dir}/${LogFile}"
}

update() {
	logThis "Running apt-get update"
	getUpdates=$(sudo /usr/bin/apt-get -qy update > /dev/null)
	[ $? != 0 ] && { logThis "apt-get update had an error.  Stopping now!"; exit 1; } || { logThis "apt-get update completed successfully."; }
}

upgrade() {
	logThis "Running apt-get dist-upgrade (this may take some time.  Patience.)"
	getUpgrades=$(sudo /usr/bin/apt-get -qy dist-upgrade > /dev/null)
	[ $? != 0 ] && { logThis "apt-get dist-upgrade had an error.  Stopping now!"; exit 1; } || { logThis "apt-get dist-upgrade completed successfully."; }
}

sshServer() {
	sshCheck=$(netstat -natp | grep [s]shd | grep LISTEN | grep -v tcp6)
	[ $? != 0 ] && { logThis "openssh-server is NOT installed."; installOpenssh; } || { logThis "openssh-server is running."; }
}

installOpenssh() {
	logThis "Installing openssh-server."
	installSSH=$(sudo /usr/bin/apt-get install openssh-server -qy)
	[ $? != 0 ] && { logThis "apt-get install openssh-server had an error.  Stopping now!"; exit 1; } || { logThis "apt-get install openssh-server completed successfully."; }
}

setNetwork() {
	echo -n "Do you want to set a static IP? [y|n]:"
	read -n 1 replySTATIC
	echo " "
	[ "${replySTATIC}" != "y" ] && { logThis "Keeping DHCP settings."; } || { static; }
}

static() {
	echo -n "Type the IP address for this server: "
	read IP
	echo -n "Is this correct? ${IP} [y|n]: "
	read -n 1 replyIP
	echo " "
	[ "${replyIP}" != "y" ] && { logThis "Keep calm, carry on.  Lets start over"; setNetwork; } || { logThis "Setting IP for ${IP}"; }

	echo -n "Type the subnet mask for this server: "
	read MASK
	echo -n "Is this correct? ${MASK} [y|n]: "
	read -n 1 replyMASK
	echo " "
	[ "${replyMASK}" != "y" ] && { logThis "Keep calm, carry on.  Lets start over"; setNetwork; } || { logThis "Setting subnet mask for ${MASK}"; }

	echo -n "Type the Gateway for this server: "
	read GATE
	echo -n "Is this correct? ${GATE} [y|n]: "
	read -n 1 replyGATE
	echo " "
	[ "${replyGATE}" != "y" ] && { logThis "Keep calm, carry on.  Lets start over"; setNetwork; } || { logThis "Setting Gateway for ${GATE}"; }

	echo -n "Type your DNS servers IP address (separated by a space): "
	read DNS
	echo -n "Is this correct? ${DNS} [y|n]: "
	read -n 1 replyDNS
	echo " "
	[ "${replyDNS}" != "y" ] && { logThis "Keep calm, carry on.  Lets start over"; setNetwork; } || { logThis "Setting DNS servers for ${DNS}"; }

	echo -n "Type the DNS Search Name: "
	read SEARCH
	echo -n "Is this correct? ${SEARCH} [y|n]: "
	read -n 1 replySEARCH
	echo " "
	[ "${replySEARCH}" != "y" ] && { logThis "Keep calm, carry on.  Lets start over"; setNetwork; } || { logThis "Setting DNS Search Name for ${SEARCH}"; }

	echo "Final check!"
	echo "address ${IP}"
	echo "netmask ${MASK}"
	echo "gateway ${GATE}"
	echo "dns-nameservers ${DNS}"
	echo "dns-search ${SEARCH}"
	echo " "
	echo -n "Is this correct? ${SETSTATIC} [y|n]: "
	read -n 1 replySET
	echo " "
	[ "${replySET}" != "y" ] && { logThis "You got this far and want to cancel?  Lets just stop and be safe."; exit 1; } || { setInterface "${IP}" "${MASK}" "${GATE}" "${DNS}" "${SEARCH}"; }
}

setInterface () {
	logThis "Setting new Static IP address, and restarting eth0"
	interface="/etc/network/interfaces"

	echo "# This file describes the network interfaces available on your system" > "${interface}"
	echo "	# and how to activate them. For more information, see interfaces(5)." >> "${interface}"
	echo " " >> "${interface}"
	echo "	# The loopback network interface" >> "${interface}"
	echo "	auto lo" >> "${interface}"
	echo "	iface lo inet loopback" >> "${interface}"
	echo " " >> "${interface}"
	echo "	# The primary network interface" >> "${interface}"
	echo "	auto eth0" >> "${interface}"
	echo "	iface eth0 inet static" >> "${interface}"
	echo " " >> "${interface}"
	echo "address ${1}" >> "${interface}"
	echo "netmask ${2}" >> "${interface}"
	echo "gateway ${3}" >> "${interface}"
	echo "dns-nameservers ${4}" >> "${interface}"
	echo "dns-search ${5}" >> "${interface}"

	sudo ifdown eth0
	sudo ifup eth0
}

findName () {
	logThis "Finding your IP Address and DNS record"
	ipAddress=`ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1`
	dnsName=`echo "${ipAddress}" | awk -F " " '{print $NF}' | sed 's/\.$//'`

	echo -n "Your IP address is ${ipAddress} with the DNS name ${dnsName}, correct? [y|n]: "
	read -n 1 replyIP
	echo " "
	[ "${replyIP}" != "y" ] && { logThis "You just set your IP address, and now it's wrong?  Lets just stop and be safe"; exit 1; } || { setName "${dnsName}" }
}

setName () {
	logThis "Setting your server name with the DNS record of your IP Address"
	hosts="/etc/hosts"
	hostname="/etc/hostname"

	host=`echo "${dnsName}" | awk -F "." '{print $1}'`
	echo "${host}" > "${hostname}"

	echo "127.0.0.1	localhost" > "${hosts}"
	echo "127.0.1.1	${host}	${dnsName}" >> "${hosts}"
	echo " " >> "${hosts}"
	echo "# The following lines are desirable for IPv6 capable hosts" >> "${hosts}"
	echo "::1     localhost ip6-localhost ip6-loopback" >> "${hosts}"
	echo "ff02::1 ip6-allnodes" >> "${hosts}"
	echo "ff02::2 ip6-allrouters" >> "${hosts}"
}


verifyRoot
#init
update
upgrade	
sshServer
setNetwork
findName

exit 0
