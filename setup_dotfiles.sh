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
  if [ -f $HOME/$dotfile ] ; then
    echo "backing up $HOME/$dotfile"
    mv $HOME/$dotfile $HOME/$dotfile.orig
  fi
  linkfile=`pwd`/$file
  echo "Linking $linkfile to ~/$dotfile"
  ln -s $linkfile ~/$dotfile
done
