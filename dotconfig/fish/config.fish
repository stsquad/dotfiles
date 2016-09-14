#
# Fish config
#

set -gx HOSTNAME (hostname)

if status --is-interactive;
        keychain --eval --quiet -Q id_rsa
end
