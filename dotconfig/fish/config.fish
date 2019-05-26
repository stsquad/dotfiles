#
# Fish config
#
# The aim is to keep this much more minimal than the sparwling .bash
# setup I have. However I still have some things I need to make a
# little easier.
#

set -gx HOSTNAME (hostname)

# Set up any ssh/gpg keys

# Update keys from keychains env file, see bellow for choices
function update_keys
    [ -e $HOME/.keychain/$HOSTNAME-fish ]; and . $HOME/.keychain/$HOSTNAME-fish
end

function start_keychain --description 'Start the authorative keychain instance'
    keychain -q -k all --agents ssh
    keychain -q --agents ssh --systemd
    update_keys
    ssh-add
end

# Bling
if status --is-login; and type -q neofetch;
    neofetch
end

# If this is a login shell we want to definitively set the agent (forwarded or local)
if status --is-login;
    set -l report

    if type -q keychain;
        if test -S $SSH_AUTH_SOCK; and set -q SSH_TTY
            # ensure we squash any SSH_AGENT_PID in the env which can confuse keychain
            set -e SSH_AGENT_PID
            keychain -q -k all --inherit any --agents ssh --systemd
            # the second call ensures we update all the saved configs
            keychain -q --inherit any
            set report "Using forwarded ssh agent"
        else if set -q SOMMELIER_VERSION
            keychain -q -k others --agents ssh --systemd
            set report "Using local ssh agent (crostini)"
        else
            keychain -q -k others --clear --agents ssh --systemd
            set report "Using local ssh agent"
        end
    else
        set report "missing keychain!!"
    end

    printf "$report\n"
end

if status --is-interactive;
    update_keys
end


# Helper for managing duplicates
# From: https://github.com/fish-shell/fish-shell/issues/296
function varclear --description 'Remove duplicates from environment variable'
    if test (count $argv) = 1
        set -l newvar
        set -l count 0
        for v in $$argv
            if contains -- $v $newvar
                set count (math $count+1)
            else
                set newvar $newvar $v
            end
        end
        set $argv $newvar
        # test $count -gt 0
        # and echo Removed $count duplicates from $argv
    else
        for a in $argv
            varclear $a
        end
    end
end

function add_world --description 'Add <path/[bin|lib]> to PATH and LD_LIBRARY_PATH'
    if test -n "$argv[1]"; and test -d $argv[1]
        if test -d $argv[1]/bin
            set PATH $argv[1]/bin $PATH
            varclear PATH
        end
        if test -d $argv[1]/lib
           set LD_LIBRARY_PATH "$argv[1]/lib:$LD_LIBRARY_PATH"
           varclear LD_LIBRARY_PATH
        end
        return 0
    end
    return -1
end

# Add paths to search for executables. ~/bin may contain things like
# mosh for logins so we always add it. The others are for interactive
# use only.

add_world $HOME

if status --is-interactive
   add_world ~/.local
   add_world ~/.cargo
end

# TMUX setup
if status --is-interactive
    and set -q TMUX
    set -g LP_ENABLE_TITLE
    set -g LP_ENABLE_TMUX
end

function ta --description "ta <session>"
    tmux attach -d -t $argv[1]; or tmux new -s $argv[1] fish
end

# Emacs Setup
function setup_emacs --description "Setup emacs [path to install]"
    set -l report
    if add_world $argv[1]
        set report "Using Emacs in $argv[1]"
    else
        set report "Using System Emacs"
    end
    if set -q TMUX; and tmux info  | grep "Tc" | grep "true" > /dev/null
        set -gx EMACS_TERM screen-24bits
        set report "$report with $EMACS_TERM"
        if test -n "$TMUX_PANE"
            tmux bind E new-window -n "Emacs" -t 0 -k "TERM=$EMACS_TERM emacsclient -a '' -t"
        end
    end
    printf "$report\n"
end

function launch_emacs --description "Launch the Emacs Client with whatever tweaks we need"
    if set -q EMACS_TERM
        set -lx TERM $EMACS_TERM
        emacsclient -a '' $argv
    else
        emacsclient -a '' $argv
    end
end

# set the path if it is there
if status --is-interactive
   setup_emacs $HOME/src/emacs/install
end

alias ec="launch_emacs -c -n"
alias ect="launch_emacs -t"
alias dired="launch_emacs -t -e '(my-dired-frame default-directory)'"

set -gx EDITOR "emacsclient -a ''"

# Reload config
function .fish
    source ~/.config/fish/config.fish
end
