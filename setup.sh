#!/bin/bash

get_docs () {
    scp snt@spooq.website:~/bkup/docs.bz2.enc ~
    openssl enc -d -aes-256-cbc -in ~/docs.bz2.enc -out ~/docs.bz2
    echo "extracting..."
    tar xjf ~/docs.bz2 -C ~/
    rm ~/docs.bz2*
}

get_dotfiles () {
    if [[ -d ~/docs/dotfiles ]]; then
        echo "copying dotfiles"
        ls -al ~/docs/dotfiles
        cp ~/docs/dotfiles/.* ~
        rm -rf ~/docs/dotfiles
        source ~/.bashrc
    else
        echo "~/docs/dotfiles not found"
    fi
    if [[ -d ~/docs/.emacs.d ]]; then
        echo "copying emacs conf"
        cp -r ~/docs/.emacs.d ~
        rm -rf ~/docs/.emacs.d
    else
        echo "~/docs/.emacs.d not found"
    fi
}

setup_git () {
    got_git=$(which git)
    if [[ -z $got_git ]]; then
        sudo apt install git
    fi
    ./add_scripts.sh
    git_setup
}

get_docs
get_dotfiles
setup_git

