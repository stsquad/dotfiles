#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

eval `keychain -q -Q --eval`
st -f 'Liberation Mono:size=14' -e $@ || stterm -f 'Liberation Mono:size=16' -e $@
