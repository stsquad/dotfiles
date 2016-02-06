#!/bin/bash
#
# i3 display setup
#
# It was too painful doing in the main config so I thought it would make more
# sense to encapsulate all the magic in here
#
#
HOST=`hostname`

case $HOST in
    danny*)
        xrandr --output HDMI2 --auto
        xrandr --output VGA1 --auto
        xrandr --output VGA1 --left-of HDMI2
        ;;
    zen*)
        xrandr --output HDMI1 --auto
        xrandr --output VGA1 --auto
        xrandr --output HDMI1 --primary
        xrandr --output VGA1 --left-of HDMI1
        ;;
    *)
        echo "No display support for ${HOST}"
        ;;
esac

# Run redshift if I have it
if [[ -f /usr/bin/redshift ]]; then
    redshift -l 52.29:0.21 &
fi

# Set background 
xsetroot -solid "#333333"
