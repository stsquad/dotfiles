#!/bin/bash
#
# List summary of all branches
#

if [[ -z $1 ]]; then
    headspec="refs/heads/"
else
    headspec="refs/heads/$1"
fi

if [[ -z $2 ]]; then
    reference="origin/master"
else
    reference=$2
fi

heads="`git for-each-ref --format='%(refname)' $headspec`"
for h in ${heads}; do
    merged=`git cherry $reference $h | grep "^-" | wc -l`
    unmerged=`git cherry $reference $h | grep "^+" | wc -l`
    if [[ $unmerged -gt 0 ]]; then
        status="%Cgreen-${merged}/%Cred+${unmerged}%Creset"
    else
        status="%CgreenMERGED%Creset"
    fi 
    git log -1 --oneline --format=format:"%C(auto)%h (%Cgreen${h#refs/heads/}%Creset, $status, %cr) %s" $h
done
