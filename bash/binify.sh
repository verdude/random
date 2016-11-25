#!/bin/bash

if [ ! $# -eq 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

if [ -f $1 ]; then
    if [ ! -d ~/bin ]; then
        mkdir ~/bin
    fi
    fname=~/bin/`python -c "print '$1'.split('/')[-1].split('.')[0]"`
    if [ -f $fname ]; then
        echo "that script already exists..."
        exit
    fi
    echo "saving file to $fname"
    cp $1 "$fname"
    chmod 775 "$fname"
else
    echo "file does not exist..."
fi

