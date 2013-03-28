#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Version 1.0.0 - 12/15/2012

### Description 
# Goal is to find out if Gatekeeper is active.
# Only available on 10.7.5+ or 10.8.0+ OS

### Variables
osmajor=`sw_vers -productVersion | awk -F "." '{print $1}'`
osminor=`sw_vers -productVersion | awk -F "." '{print $2}'`
osrev=`sw_vers -productVersion | awk -F "." '{print $3}'`

### Functions
# Checks Gatekeeper status on 10.7.x Macs
function lionGatekeeper () {
	if [ "${osrev}" -ge "5" ]; then
		gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
		[ "${gatekeeper_status}" == "disabled" ] && { echo "<result>Disabled</result>"; } || { echo "<result>Active</result>"; }
	else
		echo "<result>N/A; Update to the latest version of Lion.</result>"
	fi
}

# Checks Gatekeeper status on 10.8.x Macs
function mtLionGatekeeper () {
		gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
		[ "${gatekeeper_status}" == "disabled" ] && { echo "<result>Disabled</result>"; } || { echo "<result>Active</result>"; }
}

[ "${osminor}" \< "7" ] && { echo "<result>Gatekeeper N/A for this OS</result>"; }
[ "${osminor}" == "7" ] && { lionGatekeeper; }
[ "${osminor}" == "8" ] && { mtLionGatekeeper; }
exit 0
