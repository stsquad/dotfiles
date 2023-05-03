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

# Hack kitty if ssh/mosh as we don't always have the +kitten
# We could test to see if xterm-kitty is on remote machine?
# Also we seem to somehow flush ssh-agent keys while launching?
kitty="kitty"
#if test "${cmd#*ssh}" != "$cmd" ||
#        test "${cmd#*mosh}" != "$cmd" ; then
#     kitty="notkitty"
#fi
if terminal=$(command -v foot) && test -n "$WAYLAND_DISPLAY"; then
    if test "${cmd#*ssh}" != "$cmd" ||
       test "${cmd#*mosh}" != "$cmd" ||
       test ! -S "/run/user/$(id -u)/foot-wayland-0.sock"; then
        terminal="nohup $terminal $cmd >/dev/null 2>&1 &"
    else
        terminal="footclient $cmd"
    fi
elif terminal=$(command -v "alacritty"); then
    terminal="$terminal $cmd"
elif terminal=$(command -v "$kitty"); then
    # if ssh/mosh, don't standalone as we loose our SSH_AUTH_SOCK
    if test "${cmd#*ssh}" != "$cmd" ||
       test "${cmd#*mosh}" != "$cmd" ; then
        standalone=""
        cmd="kitty +kitten $cmd"
        # prevent ssh-agent being flushed by kitty running an
        # interactive login shell under our feet: https://github.com/kovidgoyal/kitty/issues/3889
	export EDITOR=zile
    else
        standalone="-1"
    fi
    terminal="$terminal --detach $standalone -o font_family='$font' -o font_size=$fontsize $cmd"
elif terminal=$(command -v st) || terminal=$(command -v stterm); then
    terminal="nohup $terminal -f '$font:size=$fontsize' $cmd >/dev/null 2>&1 &"
fi
eval "$terminal"
