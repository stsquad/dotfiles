#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

SHELL=/bin/sh

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

eval `keychain -q -Q --eval`
$dir/terminal.sh $@
