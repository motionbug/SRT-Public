#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Version 1.0.0 - 9/23/2012
### Description 
# Goal is to find out if Recovery HD is available on the Boot drive (vs. an external drive). 
# May not really matter, but for our purpose it is best practice.

### Variables
recoveryID=`diskutil list | grep "disk0" | grep "Recovery HD" | awk '{print $NF}'`

### Functions
[ "${recoveryID}" != "" ] && { echo "<result>Available</result>"; } || { echo "<result>Not Available</result>"; }
exit 0
