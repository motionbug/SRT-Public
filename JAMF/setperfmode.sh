#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-11-19

# Modified by
# Version 


### Description 
# Goal is to enable setprefmode to true if machine has Server.app configured. 

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"


# Script Variables

# Script Functions
set_setperfmode () {
    if serverinfo -q --configured; then setperfmode="TRUE"; else setperfmode="FALSE"; fi
    [[ "${setperfmode}" == "TRUE" ]] && { serverinfo --setperfmode TRUE; echo "$?"; }
}

set_setperfmode

exit 0
