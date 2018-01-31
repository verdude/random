#!/usr/bin/env bash

if [[ "$#" -eq 1 ]]; then
    if [[ -d "$GITDIR/$1" ]]; then
        pushd "$GITDIR/$1"
    else
        echo "Brooooo...that's a fake dir."
    fi
else
    echo "Brother..."
fi

