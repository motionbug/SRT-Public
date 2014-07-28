#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE

# Created by Justin Rummel
# Version 1.0.0 - 2014-5-22

# Modified by
# Version


### Description
# Goal is to download and install the current version of Prey and mass deploy to machines.
#	Must have a Pro account to get API privileges.

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
myAPI="xxxxxx"

# Script Functions
verifyRoot () {
    #Make sure we are root before proceeding.
    [ `id -u` != 0 ] && { echo "$0: Please run this as root."; exit 0; }
}

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

readyGO () {
	# function variables
	currentPrey=`curl -s https://preyproject.com/releases/bash-client/current/ | grep mpkg | grep -v md5sum | awk -F "\"" '{print $2}'`
	preyPKG=`echo "${currentPrey}" | sed 's/\.zip//g'`

	# Download current version to /tmp
	curl https://preyproject.com/releases/bash-client/current/"${currentPrey}" -o "/tmp/${currentPrey}"

	# unzip
	unzip "/tmp/${currentPrey}" -d "/tmp/"

	# clear the path
	# rm -rf /usr/share/prey

	# install
	API_KEY=["${myAPI}"] sudo -E installer -pkg /tmp/"${preyPKG}" -target / -verbose

	# Testing install
	/usr/share/prey/prey.sh -v
}

verifyRoot
init
readyGO

exit 0
