#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-08-30

# Modified by
# Version 


### Description 
#  Find the Vendor (Apple or Oracle) for the current installed version of Java.  
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
#java 
javaVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleIdentifier`
javaVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleVersion`

#Xprotect
sourceDir="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
file="XProtect.plist"
metaFile="XProtect.meta.plist"


# Script Functions
appleJava () {
	appleX=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.apple.java.JavaAppletPlugin:MinimumPlugInBundleVersion" "${sourceDir}${metaFile}"`

#	echo "${appleX}"
#	echo "${javaVersion}"

	[[ "${appleX}" > "${javaVersion}" ]] && { echo "<result>Outdated</result>"; } || { echo "<result>Compliant</result>"; }
}

oracleJava () {
	oracleX=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.oracle.java.JavaAppletPlugin:MinimumPlugInBundleVersion" "${sourceDir}${metaFile}"`

#	echo "${oracleX}"
#	echo "${javaVersion}"

	[[ "${oracleX}" > "${javaVersion}" ]] && { echo "<result>Outdated</result>"; } || { echo "<result>Compliant</result>"; }
}

[ "$javaVendor" == "" ] && { echo "<result>No Java Plug-In Available</result>"; exit 0; }
[ "$javaVendor" == "com.apple.java.JavaAppletPlugin" ] && { appleJava; }
[ "$javaVendor" == "com.oracle.java.JavaAppletPlugin" ] && { oracleJava; }

exit 0;
