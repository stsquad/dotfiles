#!/bin/bash
#
# Setup initial layout, not quite a saved session but close
#

# FIXME: only spawn terminals if non exist
for i in `seq 0 9`; do
    i3-msg "workspace number $i; exec urxvtc --loginShell || urxvt --loginShell"
done

# extra terminals in 1
i3-msg "workspace 1"
i3-msg "exec urxvtc -e /bin/bash --rcfile ~/.bash_profile"
i3-msg 'rename workspace to "1: Shells"'

# set up 2 for work
i3-msg "workspace 2"
i3-msg 'rename workspace to "2: Work"'

# set-up 8 for media
i3-msg "workspace 8"
i3-msg 'rename workspace to "8: Media"'

# and 0 is main
i3-msg "workspace 0"
i3-msg 'rename workspace to "0: Main"'
