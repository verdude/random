#!/bin/bash

set -e

rmd=$([[ "$1" = "-rmd" ]] && echo true)


setup_git () {
    got_git=$(which git)
    if [[ -z $got_git ]]; then
        sudo apt install git
    fi
    chmod 775 bash/git_setup.sh
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

del_folders () {
    for x in $(ls ~ | grep "^[A-Z]"); do
        rm -rf ~/$x
    done
}

del_folders
./add_scripts.sh
setup_git
setup_vim
setup_tmux

