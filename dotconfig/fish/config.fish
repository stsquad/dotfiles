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
    keychain -q -k all
    keychain -q -Q
    update_keys
    ssh-add
end

# If this is a login shell we want to definitively set the agent (forwarded or local)
if status --is-login;
    set -l report

    if type -q keychain;
        if test -S $SSH_AUTH_SOCK;
            keychain -q -k all --inherit any --agents ssh --systemd
            # keychain doesn't seem to save the parameters so lets do it here
            echo "set -e SSH_AUTH_SOCK; set -x -U SSH_AUTH_SOCK $SSH_AUTH_SOCK;" > $HOME/.keychain/$HOSTNAME-fish
            echo "set -e SSH_AGENT_PID;" >> $HOME/.keychain/$HOSTNAME-fish
            set report "Using forwarded ssh agent"
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

# Add ~/bin
add_world $HOME
add_world ~/.local
add_world ~/.cargo

# TMUX setup
if status --is-interactive
    and set -q TMUX
    # set -g LP_ENABLE_TITLE
    # set -g LP_TITLE_OPEN "\033k"
    # set -g LP_TITLE_CLOSE "\033\\"

    # This runs as well as the liquid prompt, it purely updates the TMUX title
    function update_tmux_title -d "Update TMUX pane title" -e fish_prompt
        printf "\033k%s(f!)\033\\" (prompt_pwd)
    end
end

function ta --description "ta <session>"
    tmux attach -d -t $argv[1]; or tmux new -s $argv[1] fish
end

# Emacs Setup
function setup_emacs --description "Setup emacs [path to install]"
    set -l report
    if add_world $argv[1]
        set report "Using Emacs in $argv[1]"
        if set -q TMUX; and tmux info  | grep "Tc" | grep "true" > /dev/null
            set -gx EMACS_TERM screen-24bits
            set report "$report with $EMACS_TERM"
            if test -n "$TMUX_PANE"
                tmux bind E new-window -n "Emacs" -t 0 -k "TERM=$EMACS_TERM emacsclient -a '' -t"
            end
        end
    else
        set report "Using System Emacs"
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

# set the path if it's there
setup_emacs $HOME/src/emacs/install

alias ec="launch_emacs -c -n"
alias ect="launch_emacs -t"
alias dired="launch_emacs -t -e '(my-dired-frame default-directory)'"

set -gx EDITOR "emacsclient -a ''"

# Reload config
function .fish
    source ~/.config/fish/config.fish
end
