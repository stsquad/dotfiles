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

# Bling (replace with fastfetch once we go to trixie)
if status --is-login;
    if type -q fastfetch;
        fastfetch
    else if type -q neofetch;
        neofetch
    end
end

# If this is a login shell we want to definitively set the agent (forwarded or local)
if status --is-login;
    set -l report

    if test -n "$DISPLAY"; and test -S $DISPLAY;
       set report "keeping forwarded agent for $DISPLAY"
    else if type -q keychain;
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
        if test -S $SSH_AUTH_SOCK
            set report "missing keychain but have an agent"
        else
            set report "missing keychain and no agent"
        end
    end

    printf "$report\n"
end

if status --is-interactive; and type -q keychain
    if test -n "$DISPLAY"; and test -S $DISPLAY;
        print "Leaving keys untouched"
    else
        update_keys
    end
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

function add_path --description 'Add <path> to PATH'
    if test -n "$argv[1]"; and test -d $argv[1]
        set -x PATH $argv[1] $PATH
        varclear PATH
    else
        printf "didn't add $argv[1] to PATH\n"
    end
end

function add_lib --description 'Add <path> to LD_LIBRARY_PATH'
    if test -n "$argv[1]"; and test -d $argv[1]
        set -gx SHADOW_LD_LIBRARY_PATH $argv[1] $SHADOW_LD_LIBRARY_PATH
        varclear SHADOW_LD_LIBRARY_PATH
        set -gx LD_LIBRARY_PATH (string join ':' $SHADOW_LD_LIBRARY_PATH)
    else
        printf "didn't add $argv[1] to LD_LIBRARY_PATH\n"
    end
end

function add_world --description 'Add <path/[bin|lib]> to PATH and LD_LIBRARY_PATH'
    if test -z "$argv[1]"; or test ! -d $argv[1]
        return -1
    end
    set -l full_path (realpath $argv[1])
    if test -n "$full_path"; and test -d $full_path
        if test -d $full_path/bin
            add_path $full_path/bin
        end
        if test -d $full_path/sbin
            add_path $full_path/sbin
        end
        if test -d $full_path/lib
            add_lib $full_path/lib

            # Check for arch specific subdir
            set -l triple (gcc -dumpmachine)
            if test -d "$full_path/lib/$triple"
                add_lib "$full_path/lib/$triple"
            end

            # and dri drivers
            if test -d "$full_path/lib/$triple/dri"
                add_dri "$full_path/lib/$triple/dri"
            end
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

if test -d /usr/lib/ccache
    set PATH /usr/lib/ccache $PATH
end

# TMUX setup
if type -q starship
   starship init fish | source
end

if status --is-interactive
    and set -q TMUX

    # reset the default command to fish
    tmux set-option -g default-command (which fish)

    if type -q starship
        function _set_title -e fish_preexec --description 'Update the title'
            set -l npanes tmux list-panes \| wc -l
            if test (eval $npanes) -eq 1
                tmux rename-window (prompt_pwd)
            end
        end
        _set_title
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
    else
        set report "Using System Emacs"
    end
    if set -q TMUX; and tmux info  | grep "Tc" | grep "true" > /dev/null
        set -gx EMACS_TERM foot-direct
        set report "$report with $EMACS_TERM"
        if test -n "$TMUX_PANE"
            tmux bind E new-window -n "Emacs" -t 0 -k "env TERM=$EMACS_TERM emacsclient -a '' -t"
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

function clear_to_end
  commandline (commandline --cut-at-cursor)
end
bind \cc clear_to_end
bind \ck kill-whole-line


# Copy terminfos
function copy_term
    infocmp -a $TERM | ssh $argv[1] tic -x -o \~/.terminfo /dev/stdin
end

# Reload config
function .fish
    source ~/.config/fish/config.fish
end
