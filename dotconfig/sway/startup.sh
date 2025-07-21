#!/bin/sh
#
# sway startup code
#
# Mostly we are trying to ensure we have all the right environment
# variables in the right places to have screen sharing work.
#
# See: https://github.com/emersion/xdg-desktop-portal-wlr/wiki/%22It-doesn't-work%22-Troubleshooting-Checklist
#

env > ~/.sway.env

# Import the WAYLAND_DISPLAY env var from sway into the systemd user session.
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway

# Stop any services that are running, so that they receive the new env var when they restart.
systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
systemctl --user start wireplumber

# With modern gnome-session starting us we should already have
# SSH_AUTH_SOCK set to the Gnome Keyring Service

cat "/proc/$(pidof xdg-desktop-portal)/environ" tr '\0' '\n' |
    grep '^WAYLAND_DISPLAY=' > ~/xdg-desktop-portal.env

cat "/proc/$(pidof xdg-desktop-portal)/environ" tr '\0' '\n' |
    grep '^XDG_' >> ~/xdg-desktop-portal.env

# Check the state of things
systemctl --user status pipewire.socket pipewire > ~/session.env
systemctl --user status wireplumber >> ~/session.env
systemctl --user status xdg-desktop-portal >> ~/session.env
