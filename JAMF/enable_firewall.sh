#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2014-10-02

### Description 
# This is an example to always enforce the Application layer Firewall on startup

# enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# unload alf
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.useragent.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist

# load alf
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.useragent.plist

exit 0
