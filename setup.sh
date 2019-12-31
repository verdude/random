#!/usr/bin/env bash
set -e

dots_only=""
default_gitdir=${GITDIR:-~/git}
scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
reponame="random"
repo_script_dir="thechosenones"
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
            return ${2:-1}
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
            rm -ri ~/$x
        fi
    done
}

setup_dotfiles () {
    mkdir -p "$default_gitdir"
    pushd "$default_gitdir"
    default_ssh_key_path="~/.ssh/id_rsa.pub"

    if [[ -n "$github" ]]; then
        echo "Add your ssh key to github first and then rerun this script with '--dots'"
    else
        if [[ ! -d "dots" ]]; then
            git clone git@github.com:verdude/dots
            cd dots
        else
            cd dots
            git pull
        fi
        if [[ -z "$(which python3)" ]]; then
            echo "Python3 not found."
            return 1
        fi
        # python3 link.py -f
        if [[ -z "$github" ]]; then
            if [[ -n $(which xclip) ]] && [[ -f $default_ssh_key_path ]]; then
                cat $default_ssh_key_path | xclip -sel clip
                echo "add key to github (it's in the paste buffer)."
            elif [[ -f $default_ssh_key_path ]]; then
                echo
                cat $default_ssh_key_path
                echo
                echo "add key to github"
            fi
        fi
    fi
    popd
}

add_scripts () {
    ./add_scripts.sh -q
}

setup () {
    mkdir -p "$default_gitdir"
    cd "$default_gitdir"
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
}

if [[ "$UID" -ne $(stat -tc %u "$default_gitdir" 2>/dev/null) ]]; then
    if ! confirm "Do you want to use $default_gitdir as your Git Directory? [y/N]: " 0; then
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

