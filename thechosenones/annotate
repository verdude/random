#!/bin/bash

filepath="$DOTDIR/"
filename=.repos.txt
repos="$filepath$filename"

updir () {
    echo $1 | python -c "import sys;i=sys.stdin.read();i=i.rstrip('/');print i[:0-len(i.split('/')[-1])].rstrip('/')"
}

curr_lvl () {
    printf '%s\n' "${PWD##*/}"
}

remote () {
    if [[ -n $(git remote 2>/dev/null) ]]; then
        git remote get-url --all $(git remote)
    fi
}

fix_dir () {
    # prints working directory up one folder if we are in a .git folder
    # prints the working directory otherwise
    if [[ -n $(pwd | grep "\.git") ]]; then
        updir $(pwd) 
    else
        pwd
    fi
}

test_files () {
    # create the file if it doesn't exist (and the dir it's in)
    if [[ ! -f "$repos" ]]; then
        echo "making folder and links in $repos"
        mkdir -p "$filepath"
        touch "$repos"
        ln -sf $(readlink -e $repos) ~
    fi
}

annotate () {
    if [[ ! -d $1 ]] | [[ $# -ne 1 ]]; then
        >&2 echo "annotate_repo needs a directory..."
        exit 1
    else
        cd "$GITDIR/$1"
        rem=$(remote)
        # cd out of the .git directory
        cd $(fix_dir $1)
        if [[ -n $rem ]]; then
            # The file where we save the list of repositories
            test_files "$repos"
            if [[ -n $(grep $rem $repos) ]]; then
                # Take the repo out of the file if it already is in there.
                # because of name changes and stuff it might
                # be better to replace the previous remote url with the current one.
                # For some reason, the command
                # cat "$repos" | grep -v "$rem" > "$repos"
                # erases the file instead of writing the grep output to it
                remaining=$(cat "$repos" | grep -v "$rem")
                echo "$remaining" > "$repos"
            fi
            echo "git clone $rem $(curr_lvl)" >> "$repos"
        fi
    fi
}

for x in $(ls $GITDIR); do
    annotate $x
done

