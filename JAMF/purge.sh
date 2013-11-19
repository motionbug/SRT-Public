#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-11-17

# Modified by
# Version 


### Description 
# Goal is to use the purge command to clear out unused memory.  
# Confession, I feel dirty doing this

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
osx=`sw_vers -productVersion | awk -F "." '{print $2}'`

# Script Functions

# Output to stdout and LogFile.
logThis () {
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${LogFile}"; }
}

init () {
	# Make our log directory
    [ ! -d $log_dir ] && { mkdir $log_dir; }

    # Now make our log file
    if [ -d $log_dir ]; then
        [ ! -e "${log_dir}/${LogFile}" ] && { touch $log_dir/${LogFile}; logThis "Log file ${LogFile} created"; logThis "Date: ${logDateTime}"; }
    else
        echo "Error: Could not create log file in directory $log_dir."
        exit 1
    fi
    echo " " >> "${log_dir}/${LogFile}"
}

purge () {
    [[ "${osx}" == "9" ]] && { purge="/usr/sbin/purge"; }
    [[ "${osx}" == "8" ]] && { purge="/usr/bin/purge"; }
    [[ "${osx}" < "8" ]] && { logThis "Not sure if `purge` is supported on your OS."; }

    sudo "${purge}";
    [[ "$?" != "0" ]] && { logThis "Error, purge command failed with the status: $?"; }
}

purge

exit 0
