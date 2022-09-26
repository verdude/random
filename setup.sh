#!/usr/bin/env bash

set -ueo pipefail

dry_run=""
dots_only=""
server_setup=""
default_gitdir=${GITDIR:-~/git}
scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
reponame="random"
repo_script_dir="thechosenones"
github="$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep 'Permission denied (publickey).')" && :

opts () {
  while getopts Dds flag
  do
    case ${flag} in
      d) dots_only="true";;
      s) server_setup="true";;
      D) dry_run="true";;
    esac
  done
}

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

setup_git () {
  [[ -n "$dry_run" ]] && echo "git setup" && return
  $repo_script_dir/git_setup.sh
}

setup_vim () {
  [[ -n "$dry_run" ]] && echo "vim setup" && return
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
  [[ -n "$dry_run" ]] && echo "tmux setup" && return
  if [[ -d ~/.tmux/plugins/tpm ]]; then
    echo "tmux tpm already installed."
  else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

setup_folders () {
  [[ -n "$dry_run" ]] && echo "setup folders" && return
  mkdir -p ~/bin ~/dls ~/bits
  if [[ $(uname) = "Darwin" ]]; then
    echo "Skipping removing folders because macOS"
    return
  fi
  for x in $(ls ~ | grep "^[A-Z]"); do
    if [[ "$x" != "git" ]] && [[ "$x" != "dls" ]] && [[ "$x" != "bin" ]] && [[ "$x" != "bits" ]]; then
      rm -ri ~/$x
    fi
  done
}

setup_dotfiles () {
  [[ -n "$dry_run" ]] && echo "setup_dot_files" && return
  mkdir -p "$default_gitdir"
  pushd "$default_gitdir"
  default_ssh_key_path="~/.ssh/id_rsa.pub"

  if [[ -n "$github" ]]; then
    echo "Add your ssh key to github first and then rerun this script with '-d'"
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
    python3 link.py -f
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
  [[ -n "$dry_run" ]] && echo "add_scripts" && return
  ./add_scripts.sh -q
}

setup () {
  [[ -n "$dry_run" ]] && echo "random repo setup" && return
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

setup_gitdir() {
  [[ -n "$dry_run" ]] && echo "setup git dir" && return
  if [[ "$UID" -ne $(stat -tc %u "$default_gitdir" 2>/dev/null) ]]; then
    if ! confirm "Do you want to use $default_gitdir as your Git Directory? [y/N]: " 0; then
      default_gitdir=~/git
    fi
  fi
}

setup_server() {
  [[ -n "$dry_run" ]] && echo "setup server" && return
  sudo apt update
  sudo apt install -y git vim tmux ufw python3
}

opts "$@"

if [[ -n "$server_setup" ]]; then
  setup_server
fi

if [[ -n "$dots_only" ]]; then
  setup_dotfiles
  exit
fi

setup_gitdir
setup
add_scripts
setup_git
setup_folders
setup_vim
setup_tmux
setup_dotfiles

echo "done"
