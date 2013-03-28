#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 11/15/2012

# Modified by
# Version 


### Description 
# Goal is to install VMWare Tools on an Ubuntu Server.  Don't forget to mount the CD first! 

# variables
cdMNT="/mnt/cdrom/"
cdDEV="/dev/cdrom/"
vmTGZ=`find "${cdMNT}" -name "VMwareTools*"`

### Be sure to select "Install VMWare Tools" from the "Virtual Machine" dropdown menu in VMWare Fusion
[ ! -d "${cdMNT}" ] && { echo "creating ${cdMNT}"; sudo mkdir "${cdMNT}"; } || { echo "${cdMNT} already exists.  Moving on..."; }
[ ! -d "${cdDEV}" ] && { echo "mounting ${cdDEV} to ${cdMNT}"; sudo mount "${cdDEV}" "${cdMNT}"; }
cd /tmp
if [ -e "${vmTGZ}" ]; then
	cp "${cdMNT}${vmTGZ}" ./
	tar xzvf "${vmTGZ}" 
	cd vmware-tools-distrib/
	sudo apt-get install build-essential
	sudo apt-get install build-essential linux-headers-`uname -r`
	sudo ./vmware-install.pl --default
	sudo reboot
else
	echo "Something went wrong.  Stopping now."
	exit 1
fi
exit 0
