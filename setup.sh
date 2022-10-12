#!/usr/bin/env bash

set -xeo pipefail

if [[ $UID -eq 0 ]]; then
  echo "no sudo pls"
  exit 1
fi

dry_run=""
username=""
single_command=""
dots_only=""
server_setup=""
deleteself=""
exit_after_server_setup=""
default_gitdir=${GITDIR:-~/git}
scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
reponame="random"
repo_script_dir="thechosenones"
github="$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep 'Permission denied (publickey).')" && :

opts() {
  while getopts zxDdsbU:u: flag
  do
    case ${flag} in
      x) single_command="true";;
      d) dots_only="true";;
      D) dry_run="true";;
      s) server_setup="true";;
      u) username="${OPTARG}";;
      b) blockcurrent="-x";;
      z) deleteself="true";;
      e) exit_after_server_setup="true";;
    esac
  done
}

die() {
  if [[ -n "$single_command" ]]; then
    echo "Reached stopping point."
    exit 0
  fi
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
  if [[ -z "$server_setup" ]]; then
    return
  fi
  [[ -n "$dry_run" ]] && echo "setup server" && return
  if ! which apt &>/dev/null; then
    echo "could not find supported package manager."
    return
  fi
  sudo apt update
  sudo apt install -y git vim tmux ufw python3 fail2ban

  if [[ -f /etc/pam.d/chsh ]]; then
    echo "chsh -> sufficient"
    sudo sed -Ei 's/required(\s*pam_shells.so)/sufficient\1/' /etc/pam.d/chsh
  fi

  sudo chsh -s $(which nologin) root
  sudo ufw allow 22
  sudo ufw enable
  cat << EOF | sudo tee /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
findtime = 10
maxretry = 0
bantime = -1
ignoreip = $(w -h | head -1 | awk '{print $3}') 127.0.0.1
EOF
  sudo systemctl enable fail2ban
  sudo systemctl restart fail2ban
  die
}

setup_user() {
  [[ -z "$username" ]] && return
  [[ -n "$dry_run" ]] && echo "create user" && return
  ${scriptpath}/${repo_script_dir}/newuser.sh -u $username $blockcurrent

  die
}

delete_self() {
  [[ -z "$deleteself" ]] && return
  [[ -n "$dry_run" ]] && echo "delete_self" && return
  rm -rf ${scriptpath}
}

opts "$@"

setup_server
setup_user

[[ -n "$exit_after_server_setup" ]] && echo "skipping non server setup" && exit 0

setup_gitdir
setup
add_scripts
setup_git||:
setup_folders
setup_vim
setup_tmux
setup_dotfiles
delete_self

echo "done"
