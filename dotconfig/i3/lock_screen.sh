#!/bin/bash
#
# i3 screen lock command
#
# As I have to mess around with xmodmaps and the like I route all screen locking through here
#

# The initial key-sequence chosen by xcape does confuse i3lock so we reset it
xmodmap -e "keycode 8 = "

# Ensure the return key does work as intended
xmodmap -e 'keycode 36 = Return'

i3lock -c 334433
