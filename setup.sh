#!/bin/bash

get_docs () {
    scp jelly@spooq.website:~/docs.bz2.enc ~
    openssl enc -d -aes-256-cbc -in ~/docs.bz2.enc -out ~/docs.bz2
    echo "extracting..."
    tar xjf ~/docs.bz2 -C ~/
    rm ~/docs.bz2*
}

get_dotfiles () {
    if [[ -d ~/docs/dotfiles ]]; then
        echo "copying dotfiles"
        pushd ~/docs/dotfiles
        for f in $(ls -pa | grep -v /); do
            mv $f ~
        done
        popd
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
    chmod 775 bash/git_setup.sh
    bash/git_setup.sh
}

setup_vim () {
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    git clone https://github.com/powerline/fonts; cd fonts; ./install.sh; cd ../; rm -rf fonts
    # vim -c "PluginInstall|qa"
}

setup_tmux() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

del_folders () {
    for x in $(ls ~ | grep "^[A-Z]"); do
        rm -rf ~/$x
    done
}

get_docs
get_dotfiles
./add_scripts.sh
setup_git
setup_vim
setup_tmux

