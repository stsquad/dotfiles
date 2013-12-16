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
        xrandr --output HDMI1 --primary
        xrandr --output VGA1 --left-of HDMI1
        ;;
    *)
        echo "No display support for ${HOST}"
        ;;
esac

# Set background 
xsetroot -solid "#333333"
