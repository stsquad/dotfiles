#!/bin/sh
#
# Launch terminal
#

# Calculate the current DPI for the best font?
fontsize=14

# Pick a font
font="Liberation Mono"
if fc-list | grep "LiterationMono Nerd Font" > /dev/null; then
   font="LiterationMono Nerd Font"
fi

# Pick a shell, fish if we have it
cmd="$*"
cmd=${cmd:-$(command -v fish)}
cmd=${cmd:-$(command -v bash)}

# hack kitty if ssh/mosh as we don't always have the +kitten
kitty="kitty"
if test "${cmd#*ssh}" != "$cmd" ||
        test "${cmd#*mosh}" != "$cmd" ; then
    kitty="notkitty"
fi

if terminal=$(command -v "$kitty"); then
    # if ssh/mosh, don't standalone as we loose our SSH_AUTH_SOCK
    if test "${cmd#*ssh}" != "$cmd" ||
       test "${cmd#*mosh}" != "$cmd" ; then
        standalone=""
    else
        standalone="-1"
    fi
    terminal="$terminal --detach $standalone -o font_family='$font' -o font_size=$fontsize $cmd"
elif terminal=$(command -v st) || terminal=$(command -v stterm); then
    terminal="nohup $terminal -f '$font:size=$fontsize' $cmd >/dev/null 2>&1 &"
fi
eval "$terminal"
