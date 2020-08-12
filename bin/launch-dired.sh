#!/bin/sh
env > ~/launch.env
#emacsclient -a '' -e "(my-dired-frame \"$1\")"
emacsclient -a '' -e '(my-dired-frame "~/Downloads/")'
