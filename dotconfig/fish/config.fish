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


# Shell prompt tweaks
# Based on https://gist.github.com/gak/5747159
#

function _common_section
    printf $c1
    printf $argv[1]
    printf $c0
    printf ":"
    printf $c2
    printf $argv[2]
    printf $argv[3]
    printf $c0
    printf ", "
end

function section
    _common_section $argv[1] $c3 $argv[2] $ce
end

function error
    _common_section $argv[1] $ce $argv[2] $ce
end

function git_branch
    set -g git_branch (git rev-parse --abbrev-ref HEAD ^ /dev/null)
    if [ $status -ne 0 ]
        set -ge git_branch
        set -g git_unstaged 0
        set -g git_staged 0
    else
        set -g git_staged (git diff --cached --numstat | wc -l)
        set -g git_unstaged (git diff --numstat | wc -l)
    end
end

function fish_prompt --description "Display the prompt"
    # $status gets nuked as soon as something else is run, e.g. set_color
    # so it has to be saved asap.
    set -l last_status $status

    # c0 to c4 progress from dark to bright
    # ce is the error colour
    set -g c0 (set_color 005284)
    set -g c1 (set_color 0075cd)
    set -g c2 (set_color 009eff)
    set -g c3 (set_color 6dc7ff)
    set -g c4 (set_color ffffff)
    set -g ce (set_color $fish_color_error)

    set -g cok (set_color 00ff7f)
    set -g cnok (set_color b22222)

    # Clear the line because fish seems to emit the prompt twice. The initial
    # display, then when you press enter.
    printf "\033[K"

    # Current time
    printf (date "+$c2%H$c0:$c2%M$c0 ")
    if [ $last_status -ne 0 ]
        error last $last_status
        set -ge status
    end

    # Output user/hostname
    printf "%s@%s " $USER $HOSTNAME

    # Track the last non-empty command. It's a bit of a hack to make sure
    # execution time and last command is tracked correctly.
    set -l cmd_line (commandline)
    if test -n "$cmd_line"
        set -g last_cmd_line $cmd_line
        set -ge new_prompt
    else
        set -g new_prompt true
    end

    # Show last execution time and growl notify if it took long enough
    set -l now (date +%s)
    if test $last_exec_timestamp
        set -l taken (math $now - $last_exec_timestamp)
        if test $taken -gt 10 -a -n "$new_prompt"
            error taken $taken
            # Clear the last_cmd_line so pressing enter doesn't repeat
            set -ge last_cmd_line
        end
    end
    set -g last_exec_timestamp $now

    # Virtual Env
    if set -q VIRTUAL_ENV
        section env (basename "$VIRTUAL_ENV")
    end

    # Git branch and dirty files
    git_branch
    if set -q git_branch
        set out $git_branch
        # if test $git_staged_count -gt 0;
        #     set out "$out$cok:$git_staged_count"
        # end
        # if test $git_unstaged_count -gt 0;
        #     set out "$out$c0/$cnok$git_unstaged_count"
        # end
        section git $out
    end

    # Current Directory
    # 1st sed for colourising forward slashes
    # 2nd sed for colourising the deepest path (the 'm' is the last char in the
    # ANSI colour code that needs to be stripped)
    printf $c1
    printf "[%s]" (pwd | sed "s,/,$c0/$c1,g" | sed "s,\(.*\)/[^m]*m,\1/$c3,")

    # Final prompt
    printf $c4
    printf "> "
end

# Update tmux
function update_tmux_title -d "Update TMUX pane title" -e fish_prompt
    printf "\033k%s(f!)\033\\" (prompt_pwd)
end
