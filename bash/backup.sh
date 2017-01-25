#!/bin/bash

cd ~
if [[ ! -d docs ]]; then
    echo "docs folder not found."
    exit 1
fi
dryrun=$([[ "$1" = "--dry-run" ]] && echo true)

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

gitxclude () {
    find ~/docs/ -name "\.git" -type d -exec annotate_repo {} \;
}

compress_encrypt() {
    cd ~
    if [[ ! -d docs ]]; then
        echo "Docs directory not found. Exiting."
        exit 1
    fi
    echo "compressing docs..."
    excludes=$(gitxclude)
    [[ -n $dryrun ]] && echo $excludes && cleanup && exit 0
    tar $excludes -cjf docs.bz2 docs
    openssl enc -aes-256-cbc -in docs.bz2 -out docs.bz2.enc
}

backup () {
    cd ~
    if [[ -f docs.bz2.enc ]]; then
        echo "Backing up to spooq.website..."
        scp docs.bz2.enc snt@spooq.website:~/bkup/docs.bz2.enc
    else
        echo "encrypted file not found."
    fi
}

cleanup () {
    echo "cleanup..."
    rm docs.bz2
    rm -rf ~/docs/dotfiles
    rm -rf ~/docs/.emacs.d
    echo "Done"
}

check_size
dotfiles
compress_encrypt
backup
cleanup

