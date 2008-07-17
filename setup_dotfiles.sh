#!/bin/bash
#
# Alex's setup script.
#
# Install the dotfiles in my repositry into the current home directory
# using symbolic links.
#
# This script assumes its in the reposirty and all dotfiles need to go to $HOME
#

for file in dot*
do
  dotfile=`echo $file | sed s/dot/\./`
  dotfilepath=$HOME/$dotfile
  

  # Don't save orig if it's already a link
  if [ -L $dotfilepath ] ; then
    linkdest=`ls -L $dotfilepath`
    echo "skipping symlink at $dotfilepath"
  else
    if [ -f $dotfilepath ] ; then
      echo "backing up $dotfilepath"
      mv $dotfilepath $HOME/$dotfile.orig
    fi
    linkfile=`pwd`/$file
    echo "Linking $linkfile to ~/$dotfile"
    ln -s $linkfile ~/$dotfile
  fi
done
