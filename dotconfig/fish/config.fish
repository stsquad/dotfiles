#
# Fish config
#

set -gx HOSTNAME (hostname)

# Set up any ssh/gpg keys
# As fish is never the first shell let's not have it attempt to start any new agents, just inherit what is set
function update_keys
    [ -e $HOME/.keychain/$HOSTNAME-fish ]; and . $HOME/.keychain/$HOSTNAME-fish
end

if status --is-interactive;
    update_keys
end

# Helper function for copying to the NAS
function copy_to_nas -d "Copy files to the NAS"
    for f in "$argv";
        scp "$f" admin@nas:/volume1/video/
    end
end

# Update tmux
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

alias ect="emacsclient -a '' -t"
alias dired="emacsclient -a '' -t -e '(my-dired-frame default-directory)'"

# Reload config
function .fish
        source ~/.config/fish/config.fish
end
