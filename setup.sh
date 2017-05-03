#!/bin/bash

dots_only=""
default_gitdir=${GITDIR:-~/git}
directory=$(basename $(dirname $0))
reponame="random"
bitbucket=$(ssh -o StrictHostKeyChecking=no git@bitbucket.com 2>&1 | grep "Permission denied (publickey).")
github=$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep "Permission denied (publickey).")

confirm() {
    read -r -p "$1" response
    case $response in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        [Nn][Oo]|[Nn])
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

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
            if [[ ! -d ~/bin ]]; then
                echo "You should run the rest of the setup now"
                exit
            fi
            ~/bin/reclone
        fi
    fi
    popd
}

add_scripts () {
    echo $PWD
    ./add_scripts.sh
}

setup () {
    mkdir -p "$default_gitdir"
    wd="$PWD"
    pushd "$default_gitdir"
    echo "$PWD"
    if [[ ! -d "$reponame" ]]; then
        if [[ -z "$github" ]]; then
            url="git@github.com:verdude/$reponame"
        else
            url="https://github.com/verdude/$reponame"
        fi
        git clone "$url"
    fi
    cd "$reponame"
    echo "$PWD"
    nwd="$PWD"
    # delete the random repo if it isn't in the $default_gitdir
    if [[ "$wd" != "$nwd" ]]; then
    echo "$PWD"
        popd
    echo "$PWD"
        cd ..
    echo "$PWD"
        echo "deleting $nwd"
        rm -rf "$nwd"
    fi
    echo "$default_gitdir"
    cd "$default_gitdir/$reponame"
}

if [[ "$UID" -ne $(stat -tc %u "$default_gitdir" 2>/dev/null) ]]; then
    if ! confirm "Do you want to use $default_gitdir as your Git Directory? [y/N]: "; then
        default_gitdir=~/git
    fi
fi

opts "$@"
[[ -n "$dots_only" ]] && setup_dotfiles && exit
setup
add_scripts
setup_git
setup_folders
setup_vim
setup_tmux
setup_dotfiles
echo "done"

