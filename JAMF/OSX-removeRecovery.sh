#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Version 1.0.0 - 9/23/2012

### Description 
# Goal is to remove Recovery HD just in case your imaging fleet of OS X machines has it available
# This will remove the Recovery HD partition and then merge the extra space w/ the primary drive

# Script Variables
RecoveryHDName="Recovery HD"
RecoveryHDID=`/usr/sbin/diskutil list | grep "$RecoveryHDName" | awk 'END { print $NF }'`
HDName="MBA HD"
MBAHD=`/usr/sbin/diskutil list | grep "$HDName" | awk 'END { print $NF }'`

### functions
[[ "${RecoveryHDID}" != "" && "${MBAHD}" != "" ]] && { echo "Removing ${RecoveryHDName} from ${MBAHD}"; } || { echo "There is an error.  Stopping now."; exit 1; }
diskutil eraseVolume HFS+ ErasedDisk "/dev/${RecoveryHDID}"

[[ "${RecoveryHDID}" != "" && "${MBAHD}" != "" ]] && { diskutil mergePartitions HFS+ "${HDName}" "${MBAHD}" "${RecoveryHDID}"; }
exit 0
