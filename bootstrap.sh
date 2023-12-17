#!/bin/bash
# 
# Bootstrap a new system
# wget -O - https://raw.githubusercontent.com/stsquad/dotfiles/master/bootstrap.sh | bash
# curl -s https://raw.githubusercontent.com/stsquad/dotfiles/master/bootstrap.sh | bash
#
set -e

if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ "ssh-add -l > /dev/null" ]; then
    SSH_CONFIG=${HOME}/.ssh
    mkdir -p ${SSH_CONFIG}
    # You kinda have to take it on trust that these are the github finger-prints
    cat > ${SSH_CONFIG}/known_hosts <<EOF
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
# github.com:22 SSH-2.0-babeld-756a9a22
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
# github.com:22 SSH-2.0-babeld-756a9a22
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
# github.com:22 SSH-2.0-babeld-756a9a22
# github.com:22 SSH-2.0-babeld-756a9a22
EOF
    MYGITHUB=git@github.com:stsquad
else
    MYGITHUB=https://github.com/stsquad
fi

GIT=`which git`
if [[ ! -f ${GIT} ]]; then
   # Are we on an dpkg/apt based system?
   DPKG=`which dpkg-query`
   if [[ ! -f ${DPKG} ]]; then
       if [[ ! `dpkg-query --status git` ]]; then
	   echo "Fetching git"
	   if [ `id -u` = 0 ] ; then
	       apt-get update
	       apt-get install -y git
	   else
	       sudo apt-get update
	       sudo apt-get install -y git
	   fi
       fi
   else
       echo "Don't know how to install git on this system"
       exit 1
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

# Account for running under sudo
if [ ! -z "${SUDO_USER}" ]; then
    echo "Fixing up ${HOME} permissions to ${SUDO_USER}:${SUDO_GID}"
    chown -R ${SUDO_USER}:${SUDO_GID} ${HOME}
fi

# Done (for now)
echo "Done!"


