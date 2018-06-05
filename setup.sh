#!/usr/bin/env bash
set -x
set -e

dots_only=""
default_gitdir=${GITDIR:-~/git}
scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
reponame="random"
repo_script_dir="thechosenones"
bitbucket="$(ssh -o StrictHostKeyChecking=no git@bitbucket.com 2>&1 | grep 'Permission denied (publickey).')"
github="$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep 'Permission denied (publickey).')" && :

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
    for opt in "$@"; do
        if [[ "$opt" = "--dots" ]]; then
            dots_only="true"
        fi
    done
}

setup_git () {
    $repo_script_dir/git_setup.sh
}

setup_vim () {
    if [[ -d ~/.local/share/fonts ]]; then
        echo "Skipping font install."
    else
        git clone https://github.com/powerline/fonts; cd fonts; ./install.sh; cd ../; rm -rf fonts
        # vim -c "PluginInstall|qa"
    fi
    if [[ -d ~/.vim/bundle/Vundle.vim ]]; then
        echo "Skipping Vundle install"
    else
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
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
    mkdir -p ~/bin ~/dls
    if [[ $(uname) = "Darwin" ]]; then
        echo "Skipping removing folders because macOS"
        return
    fi
    for x in $(ls ~ | grep "^[A-Z]"); do
        if [[ "$x" != "git" ]] && [[ "$x" != "dls" ]] && [[ "$x" != "bin" ]] ; then
            rm -rf ~/$x
        fi
    done
}

setup_dotfiles () {
    mkdir -p "$default_gitdir"
    pushd "$default_gitdir"

    if [[ -n "$bitbucket" ]]; then
        echo "Add your ssh keys to bitbucket and github first and then rerun this script with '--dots'"
    else
        if [[ ! -d "dots" ]]; then
            git clone git@bitbucket.org:santim/dots
            cd dots
        else
            cd dots
            git pull
        fi
        ./link.py
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
    ./add_scripts.sh
}

setup () {
    mkdir -p "$default_gitdir"
    pushd "$default_gitdir"
    if [[ ! -d "$reponame" ]]; then
        if [[ -z "$github" ]]; then
            url="git@github.com:verdude/$reponame"
        else
            url="https://github.com/verdude/$reponame"
        fi
        # TODO prompt user for a different reponame if they so desire
        git clone "$url"
    fi
    cd "$reponame"
    # delete the random repo if it isn't in the $default_gitdir
    # TODO: don't delete if is not in random repo
    if [[ "$scriptpath" != "$PWD" ]]; then
        echo "deleting $scriptpath"
        rm -rf "$scriptpath"
    fi
    # TODO: check if this is the same repo that we cloned
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

