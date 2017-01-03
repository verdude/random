#!/bin/bash

cd ~
if [[ ! -d docs/dotfiles ]]; then
    echo "Making docs/dotfiles..."
    mkdir -p docs/dotfiles
fi
if [[ -d .emacs.d ]]; then
    echo "Backing up emacs conf..."
    cp -r .emacs.d docs
    echo "Done"
fi

cd ~
cp .*rc docs/dotfiles/
cp .bash* docs/dotfiles/

