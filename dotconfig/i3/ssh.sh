#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

eval `keychain -q -Q --eval`
urxvtc -e $@
