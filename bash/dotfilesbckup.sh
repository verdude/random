#!/bin/bash

cd ~
if [[ ! -d docs ]]; then
    printf "Making docs directory..."
    mkdir docs
fi
if [[ -d .emacs.d ]]; then
    echo "Backing up emacs conf..."
    cp -r .emacs.d docs
    echo "Done"
fi

cd ~
cp .*rc docs/dotfiles/
cp .bash* docs/dotfiles/

