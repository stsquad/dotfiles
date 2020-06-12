#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

SHELL=/bin/sh
eval `keychain -q -Q --eval`
st -f 'Liberation Mono:size=14' -e $@
