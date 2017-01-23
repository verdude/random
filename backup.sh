#!/bin/bash

cd ~
if [[ ! -d docs ]]; then
    echo "docs folder not found."
    exit 1
fi

dotfiles(){
    cd ~
    if [[ ! -d docs/dotfiles ]]; then
        echo "Making docs/dotfiles..."
        mkdir docs/dotfiles
    fi
    if [[ -d .emacs.d ]]; then
        echo "Backing up emacs conf..."
        cp -r .emacs.d docs
        echo "Done"
    fi

    cd ~
    cp .*rc docs/dotfiles/
    cp .bash_aliases docs/dotfiles/
}

check_size() {
    find ~/docs -type d -exec du -s {} \; | awk '$1>90000{print $0}'
}

compress_encrypt() {
    cd ~
    if [[ ! -d docs ]]; then
        echo "Docs directory not found. Exiting."
        exit 1
    fi
    echo "compressing docs..."
    tar cjf docs.tgz docs
    openssl enc -aes-256-cbc -in docs.tgz | base64 > docs.tgz.enc
    echo "cleanup..."
    rm docs.tgz
    rm -rf ~/docs/dotfiles
    rm -rf ~/docs/.emacs.d
}

backup () {
    cd ~
    if [[ -f docs.tgz.enc ]]; then
        echo "Backing up to spooq.website..."
        scp docs.tgz.enc snt@spooq.website:~/bkup/docs.tgz.enc
    else
        echo "encrypted file not found."
    fi
}

check_size
dotfiles
compress_encrypt
backup
echo "Done"

