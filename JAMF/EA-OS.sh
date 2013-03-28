#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Version 1.0.0 - 12/15/2012

### Description 
# Goal is to find out what vesion of the OS is running, PLUS if the machine is a client or server.
# Needed for Mt Lion as a "Server OS" is now depricated.  It's just an app.

### Variables
osx=`sw_vers -productVersion | awk -F "." '{print $2}'`

### Functions
oldSchool () {
	productName=`sw_vers -productName`
	productVersion=`sw_vers -productVersion`
	buildVersion=`sw_vers -buildVersion`

	echo "<result>${productName} ${productVersion} (${buildVersion})</result>"
}

newSchool () {
	if serverinfo -q --configured; then osxs=" Server"; else osxs=""; fi

	productName=`sw_vers -productName`
	productName2="${productName}${osxs}"
	productVersion=`sw_vers -productVersion`
	buildVersion=`sw_vers -buildVersion`

	echo "<result>${productName2} ${productVersion} (${buildVersion})</result>"
}

[ "${osx}" == "8" ] && { newSchool; } || { oldSchool; }

exit 0
