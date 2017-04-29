#!/bin/bash

if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

scripts_dirname="thechosenones"

check_for_random_repo () {
    # perhaps use find?
    # perhaps search for  $scripts_dirname
    if [[ -d random ]]; then
        cd random
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -n $git_root ]]; then
            if [[ -d "$scripts_dirname" ]]; then
                echo "Found $scripts_dirname directory"
            else
                echo "Repository with $scripts_dirname not found. Exiting."
                exit 1
            fi
        else
            echo "Repository with $scripts_dirname not found. Exiting."
            exit 1
        fi
    else
        echo "Rudimentary search for repo with $scripts_dirname failed. Perhaps we need a less rudimentary seach."
        exit
    fi
}

# makes sure we are in the correct directory 
# by checking the git root
check_git () {
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z $git_root ]]; then
        echo "Why are we in $PWD?"
        if [[ -z $GITDIR ]]; then
            echo '$GITDIR not found.'
            echo "Checking for 'random' repository..."
            check_for_random_repo
        else
            cd $GITDIR
            check_for_random_repo
        fi
    fi
}

link_files () {
    rel=~/bin/
    for file in $(ls $1); do
        fname=$(python -c "print '$file'.split('/')[-1].split('.')[0]")
        ln -s $(readlink -e "$scripts_dirname/$file") "$rel$fname" 2>/dev/null
    done
    echo "done"
}

main () {
    if [[ -d $scripts_dirname ]]; then
        link_files "$scripts_dirname"
    elif [[ "${PWD##*/}" = "thechosenones" ]]; then
        pushd ..
        link_files "$scripts_dirname"
        popd
    fi
}

check_git
main

