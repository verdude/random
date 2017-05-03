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

if [[ -z "$folder" ]] && [[ -f "$HOME/.bashrc" ]]; then
    # grab the env var from the bashrc file without exporting it
    dir_=$(cat "$HOME/.bashrc" | grep "GITDIR\=")
    # split at the equals, take the latter half
    GITDIR=$(eval echo "${dir_##*=}")
    # same for the dotdir env var
    dir_=$(cat "$HOME/.bashrc" | grep "DOTDIR\=")
    DOTDIR=$(eval echo "${dir_##*=}")
else
    error_exit
fi

folder="$DOTDIR"
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


