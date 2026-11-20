#!/bin/bash
#
# Alex's Claude Code config
#
# ~/.claude also holds credentials, sessions and other state so we
# can't link the whole directory. Instead link the individual bits we
# keep under version control.
#

ORIG_PATH=`pwd`
CLAUDE_DIR=$HOME/.claude
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

function link_claude_item
{
    orig=$1
    dot=$2

    # If it is already linked we will skip
    if [[ $orig -ef $dot ]] ; then
	echo "skipping symlink at $dot (linked to $orig)"
    else
	if [ -e $dot ] ; then
	    echo "backing up $dot to ${dot}.orig"
	    mv $dot ${dot}.orig
	fi

	echo "Linking $orig to $dot"
	ln -s $orig $dot
    fi
}

mkdir -p ${CLAUDE_DIR}
cd $SCRIPTPATH
for x in settings.json agents
do
    link_claude_item $SCRIPTPATH/$x $CLAUDE_DIR/$x
done
cd $ORIG_PATH
