#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Version 1.0.0 - 9/23/2012

### Description 
# Goal is to find out if a firmware password has been set.  
# Must have the 'setregproptool' installed at /usr/local/bin by a separate install
# for this to work as 'setregproptool' is not available by default in OSX.  You can 
# get it from Recovery HD, or "Install OS X Mountain Lion.app"

### Variables

### Functions
detect () {
	FPenabled=`setregproptool -c`
	[ ! "${FPenabled}" ] && { echo "<result>Enabled</result>"; } || { echo "<result>Disabled</result>"; }
}

[ -e "/usr/local/bin/setregproptool" ] && { detect; } || { echo "CLI missing"; }
exit 0
