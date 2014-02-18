#!/bin/bash
# 
# Bootstrap a new system
# wget -O - https://raw.github.com/stsquad/dotfiles/master/bootstrap.sh | bash
#
set -e

if [ -z "$SSH_AUTH_SOCK" ]; then
    MYGITHUB=git@github.com:stsquad
else
    MYGITHUB=https://github.com/stsquad
fi

# Currently assume apt based systems
if [[ ! `dpkg-query --status git-core` ]]; then
    echo "Fetching git"
    if [ `id -u` = 0 ] ; then
        apt-get update
        apt-get install -y git-core
    else
        sudo apt-get update
        sudo apt-get install -y git-core
    fi
else
    echo "Already have git, good"
fi

# keep my stff here
MYSRC=${HOME}/mysrc
mkdir -p ${MYSRC}
cd ${MYSRC}

# Clone dotfiles and elisp
if [ ! -d dotfiles.git ]; then
    echo "Fetching dotfiles"
    git clone ${MYGITHUB}/dotfiles.git dotfiles.git
    cd dotfiles.git
    ./setup_dotfiles.sh
    cd -
fi

if [ ! -d elisp.git ]; then
    echo "Fetching elisp"
    git clone ${MYGITHUB}/my-emacs-stuff.git elisp.git
    cd elisp.git
    ./setup_emacs.sh
    cd -
fi

cd $HOME

# Done (for now)
echo "Done!"


