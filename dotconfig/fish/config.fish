#
# Fish config
#

set -gx HOSTNAME (hostname)

if status --is-interactive;
        keychain --eval --quiet -Q id_rsa
end

function copy_to_nas -d "Copy files to the NAS"
    for f in "$argv";
        scp "$f" admin@nas:/volume1/video/
    end
end
