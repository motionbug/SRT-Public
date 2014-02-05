#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's Licnese found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE

# Created by Justin Rummel
# Version 1.0.0 - 1/14/2013

# Modified by
# Version


### Description
#  Find and report the current version of Flash installed

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="enable"
logDate=`date +"Y.m.d"`
logDateTime=`date +"Y-m-d_H.M.S"`
log_dir="/Library/Logs/${logtag}"
LogFile="${logtag}-${logDate}.log"

# Script Variables
#Flash (not sure why there is a .lzma in one of my test machines, but this way I find the plugin that is installed!)
fPlugin=`find /Library/Internet\ Plug-Ins -name "Flash*" -d 1 | awk -F "/" {'print $4'}`
flashVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/"${fPlugin}"/Contents/Info CFBundleIdentifier`
flashVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/"${fPlugin}"/Contents/Info CFBundleVersion`


# Script Functions
adobeFlash () {
	[ "${javaProject}" == "" ] && { echo "<result>Adobe Flash (${flashVersion})</result>"; } || { echo "<result>Oracle (${javaProject} - ${javaVersion})</result>"; }
}

[ "$flashVendor" == "" ] && { echo "<result>Flash Plug-In Not Available</result>"; exit 0; } || { adobeFlash; }


exit 0;
