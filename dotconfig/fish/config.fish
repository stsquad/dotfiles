#
# Fish config
#

set -gx HOSTNAME (hostname)

# Set up any ssh/gpg keys
if status --is-interactive;
        keychain --eval --quiet -Q id_rsa
end

# Helper function for copying to the NAS
function copy_to_nas -d "Copy files to the NAS"
    for f in "$argv";
        scp "$f" admin@nas:/volume1/video/
    end
end


