#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE

# Created by Justin Rummel
# Version 1.0.0 - 2014-5-19

# Modified by
# Version


### Description
# Goal is to notify a user that an item is available in Self Service.  Upon selecting "OK", Self Service will open.
#
# Concept: In order to deploy the 10.9.3 Combo, you first create a policy to Cache the install,
#	use this script to notify users that it is available, then create a Self Service policy to install cached item.

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="disable"
logDate=`date "+%Y-%m-%d"`
logDateTime=`date "+%Y-%m-%d_%H:%M:%S"`
log_dir="/Library/Logs/${logtag}"
LogFile="${logtag}-${logDate}.log"

# Script Variables
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

#### Info
# Usage: jamfHelper -windowType [-windowPostion] [-title] [-heading] [-description]
#	[-icon] [-button1] [-button2] [-defaultButton] [-cancelButton] [-showDelayOptions]
#	[-alignDescription] [-alignHeading] [-alignCountdown] [-timeout] [-countdown] [-iconSize]
#	[-lockHUD] [-startLaunchd] [-fullScreenIcon] [-kill]

# Options
wtype="utility"					# hud, utility
title="System Notification"
heading="Notification from your Friendly IT Helper"
message="This is a message"
iPath="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"		# Path to your icon
button1="OK"
button2="Cancel"
defaultButton="1"
cancelButton="2"

# Are we testing, or is this real?
[ "${4}" != "" ] && { message="${4}"; }

# send the command
notice=`"${jamfHelper}" -windowType "${wtype}" -title "${title}" -heading "${heading}" -description "${message}" -icon "${iPath}" -button1 "${button1}" -button2 "${button2}" -cancelButton "${cancelButton}" -defaultButton "${defaultButton}"`

# if OK, open Self Service
[ "${notice}" == 0 ] && { open -a "Self Service"; }
exit 0;
