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
function update_tmux_title -d "Update TMUX pane title" -e fish_prompt
    printf "\033k%s(f!)\033\\" (prompt_pwd)
end

# Reload config
function .fish
        source ~/.config/fish/config.fish
end
