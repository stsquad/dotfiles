#!/bin/bash
#
# Alex's setup script.
#
# Install the dotfiles in my repository into the current home directory
# using symbolic links.
#
# This script assumes it is in the repository and all dotfiles need
# to go to $HOME
#

# Link a file to an actual dotfile
function link_dotfile
{
    orig_file=$1
    dot_file=$2

    #echo "orig_file: $orig_file: dot_file: $dot_file"

    # If the dotfile is already linked we will skip
    link=`pwd -P $dot_file`
    if [[ $file -ef  $link ]] ; then
	echo "skipping symlink at $dot_file (linked to $link)"
    else
	if [ -f $dot_file ] ; then
	    echo "backing up $dot_file"
	    mv $dot_file ${dot_file}.orig
	fi

	# If there is stuff left over then remove it
	if [ -e $dot_file ] ; then
	    rm $dot_file
	fi
	orig_link=`pwd`/$orig_file
	echo "Linking $orig_link to $dot_file"
	ln -s $orig_link $dot_file
    fi
}

for file in dot*
do
  dotfile=`echo $file | sed s/dot/\./`
  dotfilepath=$HOME/$dotfile

  link_dotfile $file $dotfilepath
done

#
# Some hosts may have a subtle different setup for their
# dotfiles. Lets deal with them here
#
host=`hostname`
for file in ${host}_dot*
do
#    echo "meep:$file"
    if [ ! "$file" == "" ] ; then
	dotfile=`echo $file | sed s/${host}_dot/\./`
	dotfilepath=$HOME/$dotfile

	link_dotfile $file $dotfilepath
    fi
done
