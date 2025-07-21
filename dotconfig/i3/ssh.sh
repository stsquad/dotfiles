#!/bin/sh
#
# Launch ssh/mosh directly from WM
#

SHELL=/bin/sh

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

$dir/terminal.sh $@
