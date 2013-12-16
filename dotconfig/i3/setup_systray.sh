#!/bin/bash
#
# i3 systray apps
#

/usr/bin/pasystray &

# If we have wireless start the applet
ifconfig | grep -q wlan && nm-applet
