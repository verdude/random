#!/bin/bash

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

repo_parent () {
    updir $(git rev-parse --show-toplevel 2>/dev/null)
}

fix_dir () {
    # if we are in a .git directory
    if [[ -n $(pwd | grep "\.git") ]]; then
        updir $(pwd) 
    else
        echo $(pwd)
    fi
}

relpath(){
    python -c "import os.path; print os.path.relpath('$1','${2:-$PWD}')" ;
}

annotate () {
    if [[ ! -d $1 ]] | [[ $# -ne 1 ]]; then
        >&2 echo "annotate_repo needs a directory..."
        exit 1
    else
        cd $1
        rem=$(remote)
        cd $(fix_dir $1)
        parent_dir=$(repo_parent)
        if [[ -n $rem ]]; then
            filename=$parent_dir/.repos
            if [[ -n $(grep $rem $filename) ]]; then
                cat $filename | grep -v $rem > $filename
            fi
            echo "git clone $rem $(curr_lvl)" >> $filename
            echo "--exclude=$(relpath $(pwd) ~ )"
        fi
    fi
}

annotate $1

