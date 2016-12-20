#!/bin/bash
#
# Setup keys (once)
#

# Search through a list of alternative binaries, returning the first match
function find_alternatives ()
{
    for arg in "$@"
    do
      # --skip-alias only works with GNU which
      # file=`which --skip-alias $arg 2> /dev/null`
      file=`which $arg 2> /dev/null`
      if [ -x "$file" ]; then
	  echo "$file"
	  return
      fi
    done
    echo "/alternative/not/found"
}

# Search though a list of directories, returning first match
function find_directories ()
{
    for d in "$@"
    do
      if [ -d "$d" ]; then
	  echo "$d"
	  return
      fi
    done
    echo "/alternative/not/found"
}

#
# Handle key remapping
#
XCAPE_PATH=$(find_directories "${HOME}/src/emacs/xcape.git")
if [[ -d "${XCAPE_PATH}" && -e "${XCAPE_PATH}/xcape" ]]; then
    PATH=$XCAPE_PATH:$PATH
fi

XKBMAP=$(find_alternatives "setxkbmap")
XMODMAP=$(find_alternatives "xmodmap")
XCAPE=$(find_alternatives "xcape")
KEYMAPS=""

if [ -e ${XMODMAP} ]; then
    
    if xmodmap -pke | grep "keycode  66" | grep "Caps"; then
        # if this dies you may need to replace the Caps_Lock keydef
        # xmodmap -e "keycode 66 = Caps_Lock"
        ${XMODMAP} -e 'remove Lock = Caps_Lock' 2> /dev/null
        ${XMODMAP} -e 'keysym Caps_Lock = Control_L' 2> /dev/null
        ${XMODMAP} -e 'add Control = Control_L'
    fi
    KEYMAPS="${KEYMAPS} Caps->Ctrl"
fi

if [ -e ${XCAPE} ]; then
    killall xcape 2> /dev/null
    ${XMODMAP} -e 'keycode 36 = 0x1234'
    ${XMODMAP} -e 'add control = 0x1234'
    ${XMODMAP} -e 'keycode any = Return'
    ${XCAPE} -e '0x1234=Return'
    KEYMAPS="${KEYMAPS} StRet->Ctrl"
fi
