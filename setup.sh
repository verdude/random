#!/usr/bin/env bash

set -xeo pipefail

if [[ $UID -eq 0 ]]; then
  echo "no sudo pls"
  exit 1
fi

groups=""
secrets=""
dry_run=""
username=""
dots_only=""
deleteself=""
server_setup=""
single_command=""
exit_after_server_setup=""
default_gitdir=${GITDIR:-~/git}
scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
reponame="random"
repo_script_dir="thechosenones"
github="$(ssh -o StrictHostKeyChecking=no git@github.com 2>&1 | grep 'Permission denied (publickey).')" && :

function opts() {
  while getopts ezxDdsSbu:g: flag
  do
    case ${flag} in
      x) single_command="true";;
      d) dots_only="true";;
      D) dry_run="true";;
      s) server_setup="true";;
      S) secrets="true";;
      u) username="${OPTARG}";;
      b) blockcurrent="-x";;
      g) groups="-g ${OPTARG}";;
      z) deleteself="true";;
      e) exit_after_server_setup="true";;
    esac
  done
}

function die() {
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

function pushd () {
  command pushd $@ &> /dev/null
}

function popd () {
  command popd $@ &> /dev/null
}

function setup_git () {
  [[ -n "$dry_run" ]] && echo "git setup" && return
  $repo_script_dir/git_setup.sh
}

function setup_vim () {
  [[ -n "$dry_run" ]] && echo "vim setup" && return
  if [[ -d ~/.local/share/fonts ]]; then
    echo "Skipping font install."
  else
    git clone --depth=1 https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ../
    rm -rf fonts
  fi
}

function setup_x_themes() {
  [[ -n "$dry_run" ]] && echo "setup folders" && return
  if [[ -d $GITDIR/Xresources-themes ]]; then
    echo "Xresources-themes already installed"
  else
    git clone "https://github.com/verdude/xthemes" $GITDIR/xthemes
  fi
}

function setup_folders () {
  [[ -n "$dry_run" ]] && echo "setup folders" && return
  mkdir -p ~/bin ~/dls
  if [[ $(uname) = "Darwin" ]]; then
    echo "Skipping removing folders because macOS"
    return
  fi
  for x in $(ls ~ | grep "^[A-Z]"); do
    if [[ "$x" != "git" ]] &&
      [[ "$x" != "dls" ]] &&
      [[ "$x" != "bin" ]]; then
      rm -ri ~/$x
    fi
  done
}

function setup_dotfiles () {
  [[ -n "$dry_run" ]] && echo "setup_dot_files" && return
  mkdir -p "$default_gitdir"
  pushd "$default_gitdir"
  default_ssh_key_path="~/.ssh/id_rsa.pub"

  if [[ -n "$github" ]]; then
    echo "Add your ssh key to github first and then rerun this script with '-d'"
  else
    if [[ ! -d "dots" ]]; then
      git clone --depth=1 git@github.com:verdude/dots
      cd dots
    else
      cd dots
      git pull
    fi
    if [[ -z "$(which python3)" ]]; then
      echo "Python3 not found."
      return 1
    fi
    if [[ -n "$secrets" ]]; then
      "$default_gitdir/random/$repo_script_dir/private.sh" -xdtD "$default_git_dir/dots"
    fi
    python3 link.py -f
    if [[ -z "$github" ]]; then
      if [[ -n $(which xclip 2>/dev/null) ]] &&
        [[ -f $default_ssh_key_path ]]; then
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

function add_scripts () {
  [[ -n "$dry_run" ]] && echo "add_scripts" && return
  ./add_scripts.sh -q
}

function setup () {
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
    git clone --depth=1 "$url"
  fi
  cd "$reponame"
}

function setup_gitdir() {
  [[ -n "$dry_run" ]] && echo "setup git dir" && return
  if [[ "$UID" -ne $(stat -tc %u "$default_gitdir" 2>/dev/null) ]]; then
    if ! confirm "Do you want to use $default_gitdir as your Git Directory? [y/N]: " 0; then
      default_gitdir=~/git
    fi
  fi
}

function setup_server() {
  if [[ -z "$server_setup" ]]; then
    return
  fi
  [[ -n "$dry_run" ]] && echo "setup server" && return
  if ! which apt-get &>/dev/null; then
    echo "could not find supported package manager."
    return
  fi
  sudo apt-get update
  sudo apt-get install -y git vim tmux ufw python3 fail2ban

  if [[ -f /etc/pam.d/chsh ]]; then
    echo "chsh -> sufficient"
    sudo sed -Ei 's/required(\s*pam_shells.so)/sufficient\1/' /etc/pam.d/chsh
  fi

  local myip=$(w -hfi | head -1 | awk '{print $3}')
  sudo chsh -s $(which nologin) root
  sudo ufw allow from $myip
  (yes || true) | sudo ufw enable
  cat << EOF | sudo tee /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
findtime = 10
maxretry = 0
bantime = -1
ignoreip = $myip 127.0.0.1
EOF
  sudo systemctl enable fail2ban
  sudo systemctl restart fail2ban
  die
}

function setup_user() {
  [[ -z "$username" ]] && return
  [[ -n "$dry_run" ]] && echo "create user" && return
  ${scriptpath}/${repo_script_dir}/newuser.sh -u $username $blockcurrent $groups

  die
}

function delete_self() {
  [[ -z "$deleteself" ]] && return
  [[ -n "$dry_run" ]] && echo "delete_self" && return
  rm -rf ${scriptpath}

  die
}

opts "$@"

setup_server
setup_user

if [[ -n "$exit_after_server_setup" ]]; then
  echo "skipping non server setup"
  delete_self
  exit 0
fi

setup_gitdir
setup
add_scripts
setup_git||:
setup_folders
setup_vim
setup_dotfiles
delete_self

echo "done"
