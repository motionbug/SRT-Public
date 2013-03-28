#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 11/15/2012

# Modified by
# Version 

#variables
APNS="gateway.push.apple.com"


### APNS has several IP address.  Lets find just one
echo "Getting /one/ of the IP's for ${APNS}"
gpacIP=`dig A "${APNS}" +short | grep -v gateway | head -n 1`
[ "${gpacIP}" != "" ] && { echo "Found ${gpacIP}"; } || { echo "Uh oh... something is wrong so I'll stop."; exit 0; }

### We're really trying to find the DNS name to test
echo "Getting the PTR record for ${gpacIP}"
gpacTempDNS=`host "${gpacIP}" | awk '{print $NF}'`
gpacTrim=`echo "${gpacTempDNS}" | tail -c -2`
[ "${gpacTrim}" == "." ] && { gpacDNS=`echo "${gpacTempDNS}" | sed 's/.$//'`; } || { gpacDNS="gpacTempDNS"; }
[ gpacDNS != "" ] && { echo "Using ${gpacDNS}"; } || { echo "Uh oh... something is wrong so I'll stop."; exit 0; }

### can we connect to our specific APNS server?
echo "Testing ${gpacDNS} over port 2195"
TEST=`openssl s_client -connect "${gpacDNS}":2195 -no_ssl3 -no_tls1 | grep CONNECTED | cut -c 1-9`;
[ "${TEST}" == "CONNECTED" ] && { echo "We can connect to ${gpacDNS}!"; } || { echo "There was an error... something is blocking port 2195"; }

