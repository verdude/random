#!/bin/bash

scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

quiet="$1"

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

scripts_dirname="thechosenones"

get_clip () {
    make -C $(find $scriptpath -name clip -type d) install
}

check_for_script_folder () {
    # perhaps use find?
    # perhaps search for  $scripts_dirname
    # TODO: add a search for the scripts_dirname folder
    if [[ -d "$scripts_dirname" ]]; then
        echo "Found $scripts_dirname directory"
    else
        echo "Repository with $scripts_dirname not found. Exiting."
        exit 1
    fi
}

link_files () {
    rel=~/bin/
    for file in $(ls $1); do
        fname=$(echo "$scripts_dirname/$file" | python3 -c 'import os;import sys; print(os.path.abspath(sys.stdin.read()))')
        [[ "$quiet" != "-q" ]] && echo "$fname"
        linkname=$(python3 -c "print('$file'.split('/')[-1].split('.')[0])")
        [[ "$quiet" != "-q" ]] && echo "$linkname"
        ln -s -f "$fname" "$rel$linkname" 2>/dev/null
    done
    echo "scripts added."
}

main () {
    scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
    cd $scriptpath

    if [[ -d $scripts_dirname ]]; then
        link_files "$scripts_dirname"
    elif [[ "${PWD##*/}" = "thechosenones" ]]; then
        pushd ..
        link_files "$scripts_dirname"
        popd
    else
        check_for_script_folder
    fi
}

main

