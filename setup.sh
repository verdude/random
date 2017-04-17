#!/bin/bash


rmd=$([[ "$1" = "-rmd" ]] && echo true)

setup_git () {
    sudo apt install git
    git_setup
}

setup_vim () {
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    git clone https://github.com/powerline/fonts; cd fonts; ./install.sh; cd ../; rm -rf fonts
    # vim -c "PluginInstall|qa"
}

setup_tmux() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

setup_folders () {
    for x in $(ls ~ | grep "^[A-Z]"); do
        rm -rf ~/$x
    done
    mkdir ~/git
}

./add_scripts.sh
setup_git
setup_folders
setup_vim
setup_tmux

