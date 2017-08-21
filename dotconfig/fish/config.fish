#
# Fish config
#

set -gx HOSTNAME (hostname)

# Set up any ssh/gpg keys
function update_keys
     # keychain -q --agents ssh --inherit any-once --eval
     # keychain --eval --quiet -Q id_rsa
    [ -e $HOME/.keychain/$HOSTNAME-fish ]; and . $HOME/.keychain/$HOSTNAME-fish
end

if status --is-interactive;
    keychain --eval --quiet -Q id_rsa
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
