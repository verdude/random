#!/bin/bash

get_docs () {
    scp snt@spooq.website:~/docs.tgz.enc ~
    openssl enc -d -aes-256-cbc -in docs.tgz.enc -out docs.tgz
    tar xjf docs.tgz
}

get_dotfiles () {
    if [[ -d ~/docs/dotfiles ]]; then
        echo "copying dotfiles"
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
    mkdir ~/github && cd github
    git clone https://github.com/verude/random && cd random
    ./add_scripts.sh
    git_setup
}

