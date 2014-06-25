#!/bin/bash
# 
# Bootstrap a new system
# wget -O - https://raw.github.com/stsquad/dotfiles/master/bootstrap.sh | bash
#
set -e

if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ "ssh-add -l > /dev/null" ]; then
    SSH_CONFIG=${HOME}/.ssh
    mkdir -p ${SSH_CONFIG}
    # You kinda have to take it on trust that these are the github finger-prints
    cat > ${SSH_CONFIG}/known_hosts <<EOF
|1|clnLL0mD6yeybmELLpJW0Z3hSUU=|GYO6eB1F0D+HVTeLlP7edbabPiA= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|Ckc80vuVSIfn10uM74pb4jfDBS8=|lSc7LGFPlKVXCpmJF7EcHTVUlsg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
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


