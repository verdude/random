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
    if [[ ! -d "$scripts_dirname" ]]; then
        dir=$(find ${GITDIR:-.} -name "$scripts_dirname" -maxdepth 2 -type d -quit)
        if [[ -z "$dir" ]]; then
            echo "Repository with $scripts_dirname not found. Exiting."
            exit 1
        fi
    fi

    echo "Found $scripts_dirname directory"
}

link_files () {
    rel=~/bin/
    for file in $(ls $1); do
        fname=$(python3 -c "import os;print(os.path.abspath('$scripts_dirname/$file'))")
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

