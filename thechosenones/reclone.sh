#!/bin/bash

pushd () {
    command pushd "$@" &> /dev/null
}

popd () {
    command popd "$@" &> /dev/null
}

error_exit () {
    echo "repo file not found."
    exit
}

folder="$DOTDIR"
if [[ -z "$folder" ]] && [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
else
    error_exit
fi
filename=.repos.txt
repofile="$folder/$filename"
if [[ -f "$repofile" ]]; then
    pushd "$GITDIR"
    while read -r line; do
        directory=$(echo $line | xargs | grep -oE '[^ ]+$')
        if [[ ! -d "$directory" ]]; then
            $line
        else
            pushd "$directory"
            unstaged=$(git diff-files --name-only)
            if [[ -n "$unstaged" ]]; then
                echo "Not updating $directory due to tracked, not-staged files."
            else
                git pull
            fi
            popd
        fi
    done < "$repofile"
    popd
else
    error_exit
fi


