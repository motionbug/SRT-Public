#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's Licnese found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 1/14/2013

# Modified by
# Version 


### Description 
#  Find the Vendor (Apple or Oracle) for the current version of Java.  
#  Based on Rich's post at: http://derflounder.wordpress.com/2012/10/31/casper-extension-attribute-scripts-to-report-java-browser-plug-in-info/
#  and Christoph von Gabler-Sahm (linked via Rich)

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
javaVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleIdentifier`
javaVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleShortVersionString`
javaProject=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/version ProjectName`


# Script Functions
appleJava () {
	[ "${javaProject}" == "" ] && { echo "<result>Apple (${javaVersion})</result>"; } || { echo "<result>Apple (${javaProject} - ${javaVersion})</result>"; }
}

oracleJava () {
	[ "${javaProject}" == "" ] && { echo "<result>Oracle (${javaVersion})</result>"; } || { echo "<result>Oracle (${javaProject} - ${javaVersion})</result>"; }
}

[ "$javaVendor" == "" ] && { echo "<result>No Java Plug-In Available</result>"; exit 0;}
[ "$javaVendor" == "com.apple.java.JavaAppletPlugin" ] && { appleJava;}
[ "$javaVendor" == "com.oracle.java.JavaAppletPlugin" ] && { oracleJava;}

exit 0;