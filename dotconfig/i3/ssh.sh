#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

eval `keychain -q --eval`
urxvtc -e $@
