#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-09-11

# Modified by
# Version 


### Description 
#  Find the current installed version of Flash.  
#  And compare to XProtect

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

#Xprotect
sourceDir="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
file="XProtect.plist"
metaFile="XProtect.meta.plist"


# Script Functions
adobeFlash () {
	appleX=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.macromedia.Flash\ Player.plugin:MinimumPlugInBundleVersion" "${sourceDir}${metaFile}"`

	#echo "${appleX}"
	#echo "${flashVersion}"
	
	Xoct1=`echo "${appleX}" | awk -F "." '{print $1}'`
	Xoct2=`echo "${appleX}" | awk -F "." '{print $2}'`
	Xoct3=`echo "${appleX}" | awk -F "." '{print $3}'`
	Xoct4=`echo "${appleX}" | awk -F "." '{print $4}'`

	oct1=`echo "${flashVersion}" | awk -F "." '{print $1}'`
	oct2=`echo "${flashVersion}" | awk -F "." '{print $2}'`
	oct3=`echo "${flashVersion}" | awk -F "." '{print $3}'`
	oct4=`echo "${flashVersion}" | awk -F "." '{print $4}'`

	#echo "$Xoct1 > $oct1"
	#echo "$Xoct2 > $oct2"
	#echo "$Xoct3 > $oct3"
	#echo "$Xoct4 > $oct4"

	[[ "${Xoct1}" -gt "${oct1}" ]] && { echo "<result>Outdated</result>"; exit 0; }
	[[ "${Xoct2}" -gt "${oct2}" ]] && { echo "<result>Outdated</result>"; exit 0; }
	[[ "${Xoct3}" -gt "${oct3}" ]] && { echo "<result>Outdated</result>"; exit 0; }
	[[ "${Xoct4}" -gt "${oct4}" ]] && { echo "<result>Outdated</result>"; exit 0; } || { echo "<result>Compliant</result>"; }
}

[ "$flashVendor" == "" ] && { echo "<result>Flash Plug-In Not Available</result>"; exit 0; } || { adobeFlash; }

exit 0;
