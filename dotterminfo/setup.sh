#!/bin/bash
#
# Alex's dotterminfo
#
# Usually you want to rely on the fact that terminfo's have been
# packaged by your distro of choice. However for funky stuff such as
# 24 bit colour terminals you need to do a bit yourself.
#

ORIG_PATH=`pwd`
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

cd $SCRIPTPATH
# Process all directories in this directory
for x in *.src
do
    tic -x -o ~/.terminfo $x
done

cd $ORIG_PATH
