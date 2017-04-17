#!/bin/bash

folder=$GITDIR/dots/
filename=.repos.txt
repofile="$folder$filename"
if [[ -f "$repofile" ]]; then
    pushd "$GITDIR"
    cat "$repofile" | bash
    popd
else
    echo "repo file not found"
fi


