#!/bin/bash

dots_only=""
default_gitdir=${GITDIR:-~/git}
reponame="random"
directory=$(dirname $0)
filename=${0##*/}

pushd () {
    command pushd $@ &> /dev/null
}

popd () {
    command popd $@ &> /dev/null
}

opts () {
    for opt in $@; do
        if [[ "$opt" = "--dots" ]]; then
            dots_only="true"
        fi
    done
}

setup_git () {
    git_setup
}

setup_vim () {
    if [[ -d ~/.local/share/fonts ]]; then
        echo "Skipping font install."
    else
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        git clone https://github.com/powerline/fonts; cd fonts; ./install.sh; cd ../; rm -rf fonts
        # vim -c "PluginInstall|qa"
    fi
}

setup_tmux() {
    if [[ -d ~/.tmux/plugins/tpm ]]; then
        echo "tmux tpm already installed."
    else
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

setup_folders () {
    for x in $(ls ~ | grep "^[A-Z]"); do
        rm -rf ~/$x
    done
    mkdir -p ~/bin ~/dls
}

setup_dotfiles () {
    mkdir -p "$default_gitdir"
    pushd "$default_gitdir"

    bitbucket=$(ssh -o StrictHostKeyChecking=no git@bitbucket.com 2>&1 | grep "Permission denied (publickey).")
    github=$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep "Permission denied (publickey).")
    if [[ -n "$bitbucket" ]]; then
        echo "Add your ssh keys to bitbucket and github first and then rerun this script with '--dots'"
    else
        if [[ ! -d "dots" ]]; then
            git clone git@bitbucket.org:santim/dots
        else
            cd dots
            git pull
        fi
        ./link.sh
        source .bashrc
        if [[ -n "$github" ]]; then
            cat ~/.ssh/id_rsa.pub | xclip -sel clip
            echo "add key to github (it's in the paste buffer)"
        else
            ~/bin/reclone
        fi
    fi
    popd
}

check_for_repo () {
    # perhaps search for  $scripts_dirname
    # returns 0=true 1=false
    if [[ -d "$reponame" ]]; then
        cd "$reponame"
        return 0
    else
        echo "Rudimentary search for $reponame failed. Perhaps we need a less rudimentary seach."
        return 1
    fi
}

check_git () {
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ "$reponame" = ${git_root##*/} ]]; then 
        cd "$git_root"
    else
        echo "Why are we in $PWD?"
        if [[ -z "$GITDIR" ]]; then
            echo '$GITDIR not found.'
            echo "Checking for '$reponame' repository..."
            if ! check_for_repo; then
                exit
            fi
        else
            pushd "$GITDIR"
            if ! check_for_repo; then
                popd
                if ! check_for_repo; then
                    exit
                fi
            fi
        fi
    fi
}

add_scripts () {
    if [[ ! -f "add_scripts.sh" ]]; then
        check_git
    fi
    ./add_scripts
}

cleanup () {
    exit
}

opts "$@"
[[ -n "$dots_only" ]] && setup_dotfiles && exit
add_scripts
setup_git
setup_folders
setup_vim
setup_tmux
setup_dotfiles
cleanup
echo "done"

