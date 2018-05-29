#!/bin/bash
#
# Alex's dotconfig setup script
#
# This symlinks all subdirectories into the ${HOME}/.config setup
#

ORIG_PATH=`pwd`
CONFIG_DIR=$HOME/.config
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

function link_subdotdir
{
    orig_dir=$1
    dot_dir=$2

    # If the dotfile is already linked we will skip
    if [[ $orig_dir -ef $dot_dir ]] ; then
	echo "skipping symlink at $dot_dir (linked to $orig_dir)"
    else
	if [ -d $orig_dir ] ; then
	    echo "backing up $orig_dir to ${orig_dir}.orig"
	    mv $orig_dir ${orig_dir}.orig
	fi

	echo "Linking $dot_dir to $orig_dir"
	ln -s $dot_dir $orig_dir 
    fi
}

mkdir -p ${CONFIG_DIR}
cd $SCRIPTPATH
# Process all directories in this directory
for x in *
do
    if [ -d $x ]; then
	link_subdotdir $CONFIG_DIR/$x $SCRIPTPATH/$x
    fi
done
cd $ORIG_PATH
