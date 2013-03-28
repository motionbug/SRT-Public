#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 11/15/2012

# Modified by
# Version 

### Description 
# VMWare Fusion Backup
#===========
#
# The purpose of this script it to provide an automated system for backing up VMWare Fusion VMs that are 
# running on OS X. This is achiveved by: 
#	1) stop VMs 
#	2) tgz to /tmp
#	3) scp to a remote server 
#	4) restart VMs
# The concept for this script would be in a production environment for weekly backups
#
# This script is best used after you have established SSH keys between your client and destination server.
# See the SSH-keygen-copy.sh script in our GIT repo
#
# Because we are using SSH to copy our VMs, the keytabs are stored in your user's Home folder.  Therefore, 
# we need to copy the com.stonyrivertech.vmware.backup.plist should be stored in ~/Library/LaunchAgents/.  
# The plist is set to run on Saturdays at 11pm by default.

### Variables
# Log Settings
host=`hostname`
debug_log="enable"
logtag="backupVM"
logDate=`date +"%Y.%m.%d"`
logDateTime=`date +"%Y-%m-%d_%H.%M.%S"`

log_dir="${HOME}/Library/Logs/${logtag}"
log_runDir="/tmp/${logDate}/"
vmLogFile="${logtag}-${logDate}.log"
vmRunLog="RunningVMs-${logDate}.txt"

# VM Environment
vmrun="/Applications/VMware Fusion.app/Contents/Library/vmrun"
vmSourcePath="/Users/Shared/VM"
vmRunCount=`"${vmrun}" list | head -n 1 | awk -F ": " '{print $2}'`

# Destination server info
vmDestUser="sadmin"
vmDestServer="server.domain.tld"
vmDestPath="/Volumes/DataHD/VMBackups"



# Output to stdout and vmLogFile.
logThis () {
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${vmLogFile}"; }
}

init () {
	# Make our log directory
    [ ! -d $log_dir ] && { mkdir $log_dir; }
    [ ! -d $log_runDir ] && { mkdir $log_runDir; }

    # Make now make our log file
    if [ -d $log_dir ]; then
        [ ! -e "${log_dir}/${vmLogFile}" ] && { touch $log_dir/${vmLogFile}; logThis "Log file ${vmLogFile} created"; logThis "Date: ${logDateTime}"; }
    else
        echo "Error: Could not create log file in directory $log_dir."
        exit 1
    fi
    echo " " >> "${log_dir}/${vmLogFile}"
}

### Used for afp mounts.  Now using scp
#vmCheck () {
#	logThis "Checking to see if ${vmDestPath} is available"
#	[ ! -d "/Volumes${vmDestPath}" ] && { vmDestMount; }
#    echo " " >> "${log_dir}/${vmLogFile}"
#}

### Used for afp mounts.  Now using scp
#vmDestMount () {
#	logThis "${vmDestPath} is missing, I'll mount it for you"
#	open "${vmDestProtocol}://${vmDestUser}:${vmDestPass}@${vmDestServer}${vmDestPath}"
#    echo " " >> "${log_dir}/${vmLogFile}"
#}

vmServerCheck () {
	logThis "Is ${vmDestServer} avaiable? Starting a ping session just to be sure (Not that I don't believe you)."

	rcount=0
	until ping -o -t 5 "${vmDestServer}" ; do
		let rcount=${rcount}+1
		if [ $rcount == "15" ]; then
			logThis "Sorry, ${vmDestServer} is not available. Stopping the backup process"
			exit 0
		fi
		ifconfig -a
		sleep 1
		logThis "${vmDestServer} is not yet reachable via ping, I'll try again."
	done
}

vmDriveCheck () {
	logThis "Do we have enough space on our boot drive?"

	HDDavailable=`df -H | head -n 2 | tail -n 1 | awk '{print $4}' | sed 's/G//'`
	VMSpace=`du -h -d 1 ${vmSourcePath} | tail -n 1 | awk '{print $1}' | sed 's/G//'`

	logThis "${HDDavailable} > ${VMSpace}"
	[[ $HDDavailable > $VMSpace ]] && { logThis "We are good to go!"; } || { logThis "Houston, we may have a problem.  You have used a lot of HDD space!"; }
}

vmListCheck () {
	logThis "Checking to see if any VMs are running, and if so stop them"

	if [ "${vmRunCount}" != 0 ]; then
		logThis "\tFound ${vmRunCount} VMs running... lets stop them"
	    echo " " >> "${log_dir}/${vmLogFile}"

		[ ! -e "${log_runDir}${vmRunLog}" ] && { logThis "${vmRunLog} log file missing, I'll create one"; touch "${log_runDir}${vmRunLog}"; }
		
		for ((i=1; i <= $vmRunCount; i++))
		do
			# get the file name that is running and shut it down.  
			# We'll save the names in a file to start later
			vmFile=`"${vmrun}" list | tail -n $i | head -n 1`
			vmFileName=`echo "${vmFile}" | sed 's/.*\///' | sed 's/\.vmwarevm//'`
			
			# Generating a list first, else if there are to many it may time out and not stop everything
			logThis "\tAdding ${vmFileName} to shutdown list ${vmRunLog}"
			echo "${vmFile}" >> "${log_runDir}/${vmRunLog}"
		done
		echo " " >> "${log_dir}/${vmLogFile}"

		cat "${log_runDir}/${vmRunLog}" | while read shutdownVM;
		do
			logThis "Shutting down ${shutdownVM}"
			"${vmrun}" -T fusion stop "${shutdownVM}"
		done
		echo " " >> "${log_dir}/${vmLogFile}"
	fi

	logThis "No VMs are currently running... lets start the backups"
    echo " " >> "${log_dir}/${vmLogFile}"
}

vmSnapshot () {
	logThis "We do VM Snapshots.  Not sure why... it just seems like a good idea"

	find "${vmSourcePath}" -name "*.vmwarevm" | while read vmwarevm; 
	do
		# echo "${vmwarevm[0]}"
		vmxFile=`echo "${vmwarevm[0]}" | sed 's/.*\///' | sed 's/\.vmwarevm//'`

		logThis "\tSnapshoting $vmxFile"
		"${vmrun}" -T fusion snapshot "${vmwarevm}" "${logtag}-${logDateTime}"
	done
    echo " " >> "${log_dir}/${vmLogFile}"
}

vmBackup () {
	logThis "Will you backup my VM already!!!  Ok... starting now."

	find "${vmSourcePath}" -name "*.vmwarevm" | while read tarVM; 
	do
		# echo "${vmwarevm[0]}"
		vmxFile=`echo "${tarVM[0]}" | sed 's/.*\///' | sed 's/\.vmwarevm//'`

		if [ -e "/tmp/${logDate}/${host}-${vmxFile}-${logDate}.tgz" ]; then
			logThis "\then${vmxFile} already exists.  I'll skip this part"
		else
			logThis "\tBacking up $vmxFile"
			tar -cvzf "/tmp/${logDate}/${host}-${vmxFile}-${logDate}.tgz" "${tarVM}"
		fi
		rsync --force --ignore-errors --delete --backup --backup-dir=/"${logDate}" -az -e ssh "/tmp/${logDate}/${host}-${vmxFile}-${logDate}.tgz" "${vmDestUser}@${vmDestServer}:${vmDestPath}"
	done
    echo " " >> "${log_dir}/${vmLogFile}"
}

vmStart () {
	if [ -e "${log_runDir}/${vmRunLog}" ]; then
		logThis "We stopped some VMs in order to backup, lets restart them."
		
		cat "${log_runDir}/${vmRunLog}" | while read restartVM;
		do
			logThis "\tStarting ${restartVM}"
			"${vmrun}" -T fusion start "${restartVM}"
		done
	else
		logThis "We did not stop any VMs, so we're done"
	fi
    echo " " >> "${log_dir}/${vmLogFile}"
}

vmClean () {
	logThis "Cleaning up our mess.  Removing everything in /tmp/${logDate}"
    echo " " >> "${log_dir}/${vmLogFile}"
	rm -rf "/tmp/${logDate}/"
}

init 			# Create our log files
#vmCheck 		# Is AFP share available, if not mount.  !!!not used anymore, rsync over ssh is better
vmServerCheck 	# ping for reply on our destination server
vmDriveCheck	# HDD check.  Won't actually stop the script but good to keep track
vmListCheck 	# Are any VMs Running, stop them if yes
vmSnapshot 		# Perform a snapshot before tgz => rsync
vmBackup 		# tgz to /tmp then rsync files
vmStart 		# start any VMs that were stopped by vmServerCheck
vmClean 		# remove /tmp folder that hosted our .tgz and Running log file

exit 0