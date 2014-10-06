#!/bin/bash
#
# List branches touching
#

hashes="`git log --format=format:"%H" --branches ^origin/master -- ${1}`"
for h in ${hashes}; do
    branches=`git branch --contains $h`
    git log --oneline --format=format:"%C(auto)%h (%Cgreen${branches##  }%Creset, %cr) %s" $h^..$h
done
