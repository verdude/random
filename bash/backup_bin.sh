#!/bin/bash

have_rsync=$(which rsync)
if [[ -z have_rsync ]]; then
    echo "You need to isntall rsync"
    #exit 0
fi

cd ~
if [[ ! -d docs ]]; then
    printf "Making docs directory..."
    mkdir docs
fi
if [[ -d bin ]]; then
    echo "Backing up bin dir..."
    cp -r bin docs
    echo "Done"
fi

