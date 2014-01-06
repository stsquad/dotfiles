#!/bin/bash
# 
# Bootstrap a new system
#
#
MYGITHUB=https://github.com/stsquad/

# Currently assume apt based systems
sudo apt-get update
sudo apt-get install -y git-core

# keep my stff here
MYSRC=${HOME}/mysrc
mkdir -p ${MYSRC}
cd ${MYSRC}

# Clone dotfiles and elisp
git clone ${MYGITHUB}/dotfiles.git dotfiles.git
cd dotfiles.git
./setup_dotfiles.sh
cd -

git clone ${MYGITHUB}/my-emacs-stuff.git elisp.git
cd elisp.git
./setup_emacs.sh
cd -
cd $HOME

# Done (for now)
echo "Done!"


