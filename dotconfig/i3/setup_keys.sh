#!/bin/bash
#
# Setup keys (once)
#

# localectl doesn't seem to get this right
setxkbmap -layout gb -model extd -option "ctrl:nocaps"

# for suckless term DEL handling
# https://github.com/sakshamsharma/st-suckless-term-config/blob/master/FAQ#L54
tput smkx
