#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2014-11-24

# Modified by
# Version 


### Description 
# Goal is to force WiFi Admin settings as seen on System Preferences => Network => Wireless
# see /usr/libexec/airportd -h for more info

# Script Variables
RequireAdminIBSS="YES" 
RequireAdminNetworkChange="NO" 
RequireAdminPowerToggle="YES"

# Script Functions
/usr/libexec/airportd prefs RequireAdminIBSS="${RequireAdminIBSS}" RequireAdminNetworkChange="${RequireAdminNetworkChange}" RequireAdminPowerToggle="${RequireAdminPowerToggle}" 


exit 0
